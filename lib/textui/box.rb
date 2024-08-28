# frozen_string_literal: true

require_relative 'unicode'
require_relative 'component'

module Textui
  class Box < Component
    attr_reader :title, :x, :y, :w, :h
    attr_accessor :component
    def initialize(x, y, w, h, title: '')
      @x = x
      @y = y
      @w = w
      @h = h
      @title = title
    end

    def tick
      @component&.tick
    end

    def key_press(key)
      @component&.key_press(key)
    end

    def cursor_pos
      if (x, y = @component&.cursor_pos)
        [x + @x + 1, y + @y + 1]
      end
    end

    def prepare_render
      (title,), w = Unicode.wrap_text(@title, @w - 2)
      @line_segments = []
      l = @w - 2 - w

      @line_segments << [@x, @y, '╭' + '─' * (l / 2) + title + '─' * (l - l / 2) + '╮']
      @line_segments << [@x, @y + @h - 1, '╰' + '─' * (@w - 2) + '╯']
      (1..@h - 2).each do |y|
        @line_segments << [@x, @y + y, '│'] << [@x + @w - 1, @y + y, '│']
      end
    end

    def render
      prepare_render unless @line_segments
      clickable_fallback = @component if @component&.clickable
      segments = @component&.render&.map do |x, y, text, z, clickable|
        [@x + x + 1, @y + y + 1, text, z, clickable || clickable_fallback]
      end
      @line_segments + (segments || [])
    end
  end
end
