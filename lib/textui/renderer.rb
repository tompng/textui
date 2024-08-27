# frozen_string_literal: true

require 'io/console'

module Textui
  class Renderer
    attr_accessor :root
    FULLSCREEN_START = "\e[?1049h"
    FULLSCREEN_END = "\e[?1049l"
    RESET_CSI = "\e[0m"

    def initialize(fullscreen: false)
      @fullscreen = fullscreen
      print FULLSCREEN_START if @fullscreen
      Unicode.measure_widths
      @root = nil
      @text_widths = {}
      @rendered_lines = []
      update_winsize
      @cursor_x, @renderable_base_y = measure_cursor_pos
      @cursor_y = 0
    end

    def update_winsize
      @height, @width = $stdin.winsize
    end

    def resize
      update_winsize
      print "\e[H\e[2J"
      @cursor_y = @cursor_x = 0
      @rendered_lines = []
      @root&.resize(@width, @height)
      render
    end

    def fill_line_segments(line_segments, width_hash)
      znils, zindexed = line_segments.partition { _3 }
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

    def render
      render_differential(@root ? @root.render : [], @root&.cursor_pos)
    end

    def render_differential(line_segments, new_cursor_pos)
      new_lines = []
      text_widths = {}
      line_segments.each do |x, y, text, z|
        text_widths[text] ||= @text_widths[text] || Unicode.colored_text_width(text)
        (new_lines[y] ||= []) << [x, text, z]
      end
      new_lines.pop while new_lines.size > @height
      lines_height = [@rendered_lines.size, new_lines.size].max
      cursor_y = @cursor_y
      new_rendered_lines = []
      lines_height.times do |y|
        old_line, old_xs, old_ts = @rendered_lines[y]
        new_line = new_lines[y]
        next if old_line == new_line

        move_cursor_row_rel(y - cursor_y)
        move_cursor_col(0)
        cursor_y = y
        unless new_line
          print "\e[K"
          next
        end

        new_xs, new_ts = fill_line_segments(new_line, text_widths)
        new_rendered_lines[y] = [new_line, new_xs, new_ts]
        base_x = 0
        chunks = new_xs.take(@width).zip(new_ts, old_xs || [], old_ts || []).chunk do |nx, nt, ox, ot|
          nx == ox && nt == ot ? :skip : nx ? [nx, nt] : :blank
        end
        chunks.each do |key, chunk|
          width = chunk.size
          if key == :blank
            move_cursor_col(base_x)
            print ' ' * width
          elsif key != :skip
            x, text = key
            text_width = text_widths[text]
            text = Unicode.substr(text, x - base_x, width) if x != base_x && text_width != width
            move_cursor_col(base_x)
            print "#{RESET_CSI}#{text}#{RESET_CSI}"
          end
          base_x += width
        end
        print "\e[K"
      end

      @text_widths = text_widths
      @rendered_lines = new_rendered_lines

      new_x, new_y = new_cursor_pos || [0, 0]
      new_x = [new_x, @width - 1].min
      new_y = [new_y, @height - 1].min
      move_cursor_row_rel(new_y - cursor_y)
      move_cursor_col(new_x)
      @cursor_x = new_x
      @cursor_y = new_y
      @renderable_base_y = [@renderable_base_y, @height - lines_height, @height - @cursor_y - 1].min
    end

    def move_cursor_row_rel(dy)
      if dy < 0
        print "\e[#{-dy}A"
      elsif dy > 0
        print "\r\n" * dy
      end
    end

    def move_cursor_col(x)
      print "\e[#{x + 1}G"
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

    def terminate(clear: false)
      if @fullscreen
        print FULLSCREEN_END
      elsif clear
        render_differential([], [0, 0])
      else
        print "\r\n" * (@rendered_lines.size - @cursor_y)
      end
    end
  end
end
