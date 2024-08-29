# frozen_string_literal: true

require_relative 'unicode'
require_relative 'component'

module Textui
  class Box < Container
    attr_reader :title, :x, :y, :w, :h
    def initialize(w, h, title: '')
      super()
      @w = w
      @h = h
      @title = title
    end

    def cursor_pos
      each_with_position do |component, (cx, cy)|
        if (x, y = component.cursor_pos)
          return [cx + x, cy + y]
        end
      end
    end

    def prepare_render
      (title,), w = Unicode.wrap_text(@title, @w - 2)
      @line_segments = []
      l = @w - 2 - w

      @line_segments << [0, 0, '╭' + '─' * (l / 2) + title + '─' * (l - l / 2) + '╮']
      @line_segments << [0, 0 + @h - 1, '╰' + '─' * (@w - 2) + '╯']
      (1..@h - 2).each do |y|
        @line_segments << [0, y, '│'] << [@w - 1, y, '│']
      end
    end

    def render
      prepare_render unless @line_segments
      @line_segments.each { |x, y, t| draw(x, y, t) }
      super
    end
  end
end
