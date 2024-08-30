# frozen_string_literal: true

require_relative 'component'
require_relative 'unicode'
require_relative 'box'

module Textui
  class Textarea < Component
    attr_accessor :title, :title, :title_align
    def initialize(width, height, text: '', border: true, title: '', title_align: :center)
      @border = border ? 1 : 0
      @width = width - 2 * @border
      @height = height - 2 * @border
      @title = title
      @title_align = title_align
      @lines = text.split("\n", -1)
      @lines << '' if @lines.empty?
      @line_index = @lines.size - 1
      @byte_pointer = @lines[@line_index].bytesize
      @scroll_top = 0
    end

    def width=(width)
      @width = width
      refresh
    end

    def height=(height)
      @height = height
      refresh
    end

    def focusable = true

    def value
      @lines.join("\n")
    end

    def mouse_down(x, y)
      x -= @border
      y -= @border
      if y < 0 || y >= @height
        focus
        refresh
        return
      end
      row = -@scroll_top
      new_index, new_byte_pointer = nil
      @lines.each_with_index do |line, i|
        lines, = Unicode.wrap_text(line, @width)
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
      focus
      refresh
    end

    def key_press(key)
      case key.type
      when :escape
        blur
      when :ctrl_i
        blur(:next)
      when :shift_tab
        blur(:prev)
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
      when :left, :ctrl_b
        if @byte_pointer == 0 && @line_index > 0
          @line_index -= 1
          @byte_pointer = @lines[@line_index].bytesize
        else
          cursor_action(:move, :left, /\X/)
        end
      when :right, :ctrl_f
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
      when :ctrl_d
        if @lines[@line_index].bytesize == @byte_pointer
          @lines[@line_index, 2] = @lines[@line_index, 2].join
        else
          cursor_action(:delete, :right, /\X/)
        end
      when :meta_d
        if @lines[@line_index].bytesize == @byte_pointer
          @lines[@line_index, 2] = @lines[@line_index, 2].join
        else
          cursor_action(:delete, :right, /\P{word}*\p{word}*/)
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
      lines, = Unicode.wrap_text(current_line, @width)
      clines, col = Unicode.wrap_text(current_line.byteslice(0, @byte_pointer), @width)
      row = clines.size - 1
      if col == @width
        row += 1
        col = 0
      end
      case dir
      in :up
        if row >= 1 && lines[row - 1]
          @byte_pointer = lines[0, row - 1].sum(&:bytesize) + Unicode.substr(lines[row - 1], 0, col).bytesize
        elsif @line_index > 0
          @line_index -= 1
          (*lines, line), = Unicode.wrap_text(@lines[@line_index], @width)
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
      z_index = focused? ? 1 : nil
      @lines_to_render.each do |x, y, text|
        draw(x, y, text, z_index:, clickable: clickable)
      end
      return if @border == 0
      border_args = [@width + 2, @height + 2, { title: @title, title_align: @title_align, bold: focused? }]
      if @border_args != border_args
        @border_args = border_args
        @border_lines = Box.prepare_render(border_args[0], border_args[1], **border_args[2])
      end
      @border_lines.each { |x, y, text| draw(x, y, text, z_index:, clickable: clickable) }
    end

    def build_lines_to_render
      blank_line = ' ' * @width
      backgrounds = @height.times.map { [@border, @border + _1, blank_line] }
      wrapped_lines = []
      cursor_row = cursor_x = 0
      @lines.each_with_index do |line, i|
        lines, x = Unicode.wrap_text(line, @width)
        lines << '' if x == @width
        if i == @line_index
          clines, cx = Unicode.wrap_text(line.byteslice(0, @byte_pointer), @width)
          cursor_x = cx
          cursor_row = wrapped_lines.size + clines.size - 1
        end
        wrapped_lines.concat(lines)
      end
      if cursor_x == @width
        cursor_x = 0
        cursor_row += 1
      end

      if wrapped_lines.size <= @height
        @scroll_top = 0
      elsif @scroll_top > 0 && wrapped_lines.size - @scroll_top < @height
        @scroll_top = wrapped_lines.size - @height
      end
      if cursor_row - @scroll_top < 0
        @scroll_top = cursor_row
      elsif cursor_row - @scroll_top >= @height
        @scroll_top = cursor_row - @height + 1
      end
      @lines_to_render = backgrounds + wrapped_lines[@scroll_top, @height].each_with_index.map do |line, i|
        [@border, @border + i, line]
      end
      @cursor_pos = [@border + cursor_x, @border + cursor_row - @scroll_top]
    end
  end
end
