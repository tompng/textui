# frozen_string_literal: true

require_relative 'component'
require_relative 'unicode'

module Textui
  class Textarea < Component
    def initialize(x, y, w, h, text = '')
      @x = x
      @y = y
      @w = w
      @h = h
      @lines = text.split("\n", -1)
      @lines << '' if @lines.empty?
      @line_index = @lines.size - 1
      @byte_pointer = @lines[@line_index].bytesize
      @scroll_top = 0
    end

    def value
      @lines.join("\n")
    end

    def mouse_down(x, y)
      row = -@scroll_top
      new_index, new_byte_pointer = nil
      @lines.each_with_index do |line, i|
        lines, = Unicode.wrap_text(line, @w)
        if row + lines.size <= y
          row += lines.size
        else
          new_index = i
          new_byte_pointer = lines.take(y - row).sum(&:bytesize) + Unicode.substr(lines[y - row], 0, x).bytesize
          break
        end
      end
      @line_index = new_index || @lines.size - 1
      @byte_pointer = new_byte_pointer || @lines[@line_index].bytesize
      refresh
    end

    def key_press(key)
      case key.type
      when :ctrl_a
        cursor_action(:move, :left, /.+/)
      when :ctrl_e
        cursor_action(:move, :right, /.+/)
      when :up
        move_cursor_vertical(:up)
      when :down
        move_cursor_vertical(:down)
      when :meta_up
        @line_index = @byte_pointer = 0
      when :meta_down
        @line_index = @lines.size - 1
        @byte_pointer = @lines[@line_index].bytesize
      when :left
        if @byte_pointer == 0 && @line_index > 0
          @line_index -= 1
          @byte_pointer = @lines[@line_index].bytesize
        else
          cursor_action(:move, :left, /\X/)
        end
      when :right
        if @line_index < @lines.size - 1 && @byte_pointer == @lines[@line_index].bytesize
          @line_index += 1
          @byte_pointer = 0
        else
          cursor_action(:move, :right, /\X/)
        end
      when :char
        insert(key.raw)
      when :backspace
        if @byte_pointer == 0 && @line_index > 0 && @line_index < @lines.size
          @line_index -= 1
          @byte_pointer = @lines[@line_index].bytesize
          @lines[@line_index, 2] = @lines[@line_index, 2].join
        else
          cursor_action(:delete, :left, /\X/)
        end
      when :meta_backspace
        cursor_action(:delete, :left, /\P{word}*\p{word}*/)
      when :meta_b, :meta_left
        cursor_action(:move, :left, /\P{word}*\p{word}*/)
      when :meta_f, :meta_right
        cursor_action(:move, :right, /\P{word}*\p{word}*/)
      when :ctrl_j, :ctrl_m
        insert("\n")
      when :ctrl_k
        if @byte_pointer == @lines[@line_index].bytesize && @line_index < @lines.size - 1
          @lines[@line_index, 2] = @lines[@line_index, 2].join
        else
          cursor_action(:delete, :right, /.+/)
        end
      when :bracketed_paste
        insert(key.raw.split(/\r\n?|\n/, -1).map { _1.delete("\x00-\x1F") }.join("\n"))
      else
        insert("DEBUG[#{key.type}#{key.raw.inspect}]\n")
      end
      refresh
    end

    def insert(text, move_cursor: true)
      return if text.empty?

      pre = @lines[@line_index].byteslice(0, @byte_pointer)
      post = @lines[@line_index].byteslice(@byte_pointer..)
      *pre_lines, before_cursor = (pre + text).split("\n", -1)
      @lines[@line_index, 1] = [*pre_lines, before_cursor + post]
      if move_cursor
        @line_index += pre_lines.size
        @byte_pointer = before_cursor.bytesize
      end
    end

    def move_cursor_vertical(dir)
      current_line = @lines[@line_index]
      lines, = Unicode.wrap_text(current_line, @w)
      clines, col = Unicode.wrap_text(current_line.byteslice(0, @byte_pointer), @w)
      row = clines.size - 1
      if col == @w
        row += 1
        col = 0
      end
      case dir
      in :up
        if row >= 1 && lines[row - 1]
          @byte_pointer = lines[0, row - 1].sum(&:bytesize) + Unicode.substr(lines[row - 1], 0, col).bytesize
        elsif @line_index > 0
          @line_index -= 1
          (*lines, line), = Unicode.wrap_text(@lines[@line_index], @w)
          @byte_pointer = lines.sum(&:bytesize) + Unicode.substr(line, 0, col).bytesize
        else
          @byte_pointer = 0
        end
      in :down
        if lines[row + 1]
          @byte_pointer = lines[0, row + 1].sum(&:bytesize) + Unicode.substr(lines[row + 1], 0, col).bytesize
        elsif @line_index < @lines.size - 1
          @line_index += 1
          @byte_pointer = Unicode.substr(@lines[@line_index], 0, col).bytesize
        else
          @byte_pointer = @lines[@line_index].bytesize
        end
        lines
      end
    end

    def cursor_action(action, direction, pattern)
      pre = @lines[@line_index].byteslice(0, @byte_pointer)
      post = @lines[@line_index].byteslice(@byte_pointer..)
      text = direction == :left ? pre.reverse : post
      return unless text.start_with?(pattern)

      len = text[pattern].bytesize
      case action
      in :move
        case direction
        in :left
          @byte_pointer -= len
        in :right
          @byte_pointer += len
        end
      in :delete
        case direction
        when :left
          @lines[@line_index].bytesplice(@byte_pointer - len, len, '')
          @byte_pointer -= len
        when :right
          @lines[@line_index].bytesplice(@byte_pointer, len, '')
        end
      end
    end

    def refresh
      @lines_to_render = nil
    end

    def cursor_pos
      build_lines_to_render unless @lines_to_render
      @cursor_pos
    end

    def render
      build_lines_to_render unless @lines_to_render
      @lines_to_render
    end

    def build_lines_to_render
      blank_line = ' ' * @w
      backgrounds = @h.times.map { [@x, @y + _1, blank_line] }
      wrapped_lines = []
      cursor_row = cursor_x = 0
      @lines.each_with_index do |line, i|
        lines, x = Unicode.wrap_text(line, @w)
        lines << '' if x == @w
        if i == @line_index
          clines, cx = Unicode.wrap_text(line.byteslice(0, @byte_pointer), @w)
          cursor_x = cx
          cursor_row = wrapped_lines.size + clines.size - 1
        end
        wrapped_lines.concat(lines)
      end
      if cursor_x == @w
        cursor_x = 0
        cursor_row += 1
      end

      if wrapped_lines.size <= @h
        @scroll_top = 0
      elsif @scroll_top > 0 && wrapped_lines.size - @scroll_top < @h
        @scroll_top = wrapped_lines.size - @h
      end
      if cursor_row - @scroll_top < 0
        @scroll_top = cursor_row
      elsif cursor_row - @scroll_top >= @h
        @scroll_top = cursor_row - @h + 1
      end
      @lines_to_render = backgrounds + wrapped_lines[@scroll_top, @h].each_with_index.map do |line, i|
        [@x, @y + i, line]
      end
      @cursor_pos = [@x + cursor_x, @y + cursor_row - @scroll_top]
    end
  end
end
