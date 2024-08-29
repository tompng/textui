# frozen_string_literal: true

require_relative 'unicode'
require_relative 'component'

module Textui
  class Box < Container
    attr_reader :title, :width, :height, :title_align, :color_seq
    def initialize(width, height, title: '', title_align: :center, color_seq: '')
      super()
      @width = width
      @height = height
      @title = title
      @title_align = title_align
      @color_seq = color_seq
    end

    def self.prepare_render(width, height, title: '', title_align: :center, color_seq: '')
      (title,), w = Unicode.wrap_text(title, width - 2)
      len = width - 2 - w
      l = title_align == :left ? 0 : title_align == :right ? len : len / 2
      line_segments = []
      line_segments << [0, 0, color_seq + '╭' + '─' * l + title + '─' * (len - l) + '╮']
      line_segments << [0, 0 + height - 1, color_seq + '╰' + '─' * (width - 2) + '╯']
      v = color_seq + '│'
      (1..height - 2).each do |y|
        line_segments << [0, y, v] << [width - 1, y, v]
      end
      line_segments
    end

    def prepare_render
      arg = [width, height, { title: @title, title_align: @title_align, color_seq: @color_seq }]
      unless @arg == arg
        @line_segments = self.class.prepare_render(arg[0], arg[1], **arg[2])
        @arg = arg
      end
    end

    def render
      prepare_render
      @line_segments.each { |x, y, t| draw(x, y, t) }
      super
    end
  end
end
