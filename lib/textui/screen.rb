# frozen_string_literal: true

require 'io/console'

module Textui
  class Screen
    ENABLE_BRACKETED_PASTE = "\e[?2004h"
    DISABLE_BRACKETED_PASTE = "\e[?2004l"
    FULLSCREEN_START = "\e[?1049h"
    FULLSCREEN_END = "\e[?1049l"
    HIDE_CURSOR = "\e[?25l"
    ENABLE_MOUSE_EVENT = "\e[?1000h"
    DISABLE_MOUSE_EVENT = "\e[?1000l"
    SHOW_CURSOR = "\e[?25h"
    RESET_CSI = "\e[0m"

    def initialize(fullscreen: false)
      @mutex = Mutex.new
      @fullscreen = fullscreen
      print FULLSCREEN_START if @fullscreen
      print ENABLE_BRACKETED_PASTE
      Unicode.measure_widths
      @text_widths = {}
      @rendered_lines = []
      @rendered_line_segments = []
      update_winsize
      @cursor_x, @renderable_base_y = measure_cursor_pos
      @cursor_y = 0
    end

    def resume
      update_winsize
      print FULLSCREEN_START if @fullscreen
      print ENABLE_BRACKETED_PASTE
      @cursor_x, @renderable_base_y = measure_cursor_pos
      @cursor_y = 0
      @rendered_lines = []
      @rendered_line_segments = []
    end

    def update_winsize
      @height, @width = $stdin.winsize
    end

    def reset_screen
      update_winsize
      print "\e[H\e[2J"
      @cursor_y = @cursor_x = 0
      @renderable_base_y = 0
      @rendered_lines = []
      @rendered_line_segments = []
    end

    def resize
      update_winsize
      line_widths = @rendered_lines.map { _3&.size || 0 }
      y = (line_widths.take(@cursor_y) + [@cursor_x]).sum { [1 + (_1 - 1) / @width, 1].max }
      print move_cursor_row_rel_seq(1 - y) + "\e[J"
      @cursor_x, @renderable_base_y = measure_cursor_pos
      @cursor_y = 0
      @rendered_lines = []
      @rendered_line_segments = []
    end

    def fill_line_segments(line_segments, width_hash)
      zindexed, znils = line_segments.partition { _3 }
      zindexed = zindexed.sort_by.with_index { |(_, _, z), i| [z, i] }
      xs = []
      ts = []
      (znils + zindexed).each do |x, text|
        w = width_hash[text]
        xs.fill(x, x, w)
        ts.fill(text, x, w)
      end
      [xs, ts]
    end

    def render(component)
      @mutex.synchronize do
        render_differential(component ? component._render : [], component&.cursor_pos)
      end
    end

    def render_differential(line_segments, new_cursor_pos)
      new_lines = []
      text_widths = {}
      line_segments.each do |x, y, text, z|
        text_widths[text] ||= @text_widths[text] || Unicode.colored_text_width(text)
        (new_lines[y] ||= []) << [x, text, z]
      end
      has_clickable = line_segments.any? { _5 }

      new_lines.pop while new_lines.size > @height
      lines_height = [@rendered_lines.size, new_lines.size].max
      cursor_y = @cursor_y
      new_rendered_lines = []
      output = +''
      lines_height.times do |y|
        old_line, old_xs, old_ts = @rendered_lines[y]
        new_line = new_lines[y]
        if old_line == new_line
          new_rendered_lines[y] = [old_line, old_xs, old_ts]
          next
        end
        output << move_cursor_row_rel_seq(y - cursor_y)
        output << move_cursor_col_seq(0)
        cursor_y = y
        output << "\e[K" unless new_line && old_line
        next unless new_line

        new_xs, new_ts = fill_line_segments(new_line, text_widths)
        new_rendered_lines[y] = [new_line, new_xs, new_ts]
        base_x = 0
        chunks = new_xs.take(@width).zip(new_ts, old_xs || [], old_ts || []).chunk do |nx, nt, ox, ot|
          nx == ox && nt == ot ? :skip : nx ? [nx, nt] : :blank
        end
        chunks.each do |key, chunk|
          width = chunk.size
          if key == :blank
            output << move_cursor_col_seq(base_x)
            output << ' ' * width
          elsif key != :skip
            x, text = key
            text_width = text_widths[text]
            if x == base_x && text_width == width
              output << move_cursor_col_seq(base_x)
            else
              cover_begin = base_x > 0 && new_xs[base_x - 1] == x && new_ts[base_x - 1] == text
              cover_end = new_xs[base_x + 1] == x && new_ts[base_x + 1] == text
              pos, text = Unicode.take_range(text, base_x - x, width, cover_begin:, cover_end:, padding: true)
              output << move_cursor_col_seq(x + pos)
            end
            output << "#{text}#{RESET_CSI}"
          end
          base_x += width
        end
        if base_x < @width
          output << move_cursor_col_seq(base_x)
          output << "\e[K"
        end
      end

      @text_widths = text_widths
      @rendered_lines = new_rendered_lines
      @rendered_line_segments = line_segments

      new_x, new_y = new_cursor_pos || [0, 0]
      new_x = [new_x, @width - 1].min
      new_y = [new_y, @height - 1].min
      cursor_seq = move_cursor_row_rel_seq(new_y - cursor_y) + move_cursor_col_seq(new_x)
      if output.empty?
        output = cursor_seq + (new_cursor_pos ? SHOW_CURSOR : HIDE_CURSOR)
      else
        output = HIDE_CURSOR + RESET_CSI + output + cursor_seq + (new_cursor_pos ? SHOW_CURSOR : '')
      end
      output << (has_clickable ? ENABLE_MOUSE_EVENT : DISABLE_MOUSE_EVENT)
      print output
      @cursor_x = new_x
      @cursor_y = new_y
      @renderable_base_y = [@renderable_base_y, @height - lines_height, @height - @cursor_y - 1].min
    end

    def clickable_at(click_x, click_y)
      click_y -= @renderable_base_y
      covered = @rendered_line_segments.select do |x, y, text|
        y == click_y && x <= click_x && click_x < x + Unicode.colored_text_width(text)
      end
      zmax = covered.map { _4 }.compact.max
      clicked = covered.reverse_each.find { _4 == zmax }
      [click_x, click_y, clicked&.[](4), clicked&.[](5)]
    end

    def move_cursor_row_rel_seq(dy)
      if dy < 0
        "\e[#{-dy}A"
      elsif dy > 0
        "\r\n" * dy
      else
        ''
      end
    end

    def move_cursor_col_seq(x)
      "\e[#{x + 1}G"
    end

    def measure_cursor_pos
      $stdin.raw do
        print "\e[6n"
        (
          if $stdin.wait_readable(0.1) && /\e\[(?<row>\d+);(?<col>\d+)R/ =~ $stdin.readpartial(1024)
            [col.to_i - 1, row.to_i - 1]
          else
            [0, 0]
          end
        )
      end
    end

    def cleanup(clear: false)
      if @fullscreen
        print FULLSCREEN_END
      elsif clear
        render_differential([], [0, 0])
      else
        print "\r\n" * (@rendered_lines.size - @cursor_y)
      end
      print SHOW_CURSOR + DISABLE_MOUSE_EVENT + DISABLE_BRACKETED_PASTE
    end
  end
end
