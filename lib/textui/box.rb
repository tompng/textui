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

    BOLD = "┏┓┗┛━┃"
    FAINT = "┌┐└┘─│"
    FALLBACK='++++-|'

    def self.prepare_render(width, height, title: '', title_align: :center, color_seq: '', bold: false)
      w = 0
      unless title.empty?
        title = Unicode.substr(title, 0, width - 4)
        w = Unicode.text_width(title)
        title = "\e[1m#{title}\e[m#{color_seq}" if bold
      end
      len = width - 2 - w
      l = title_align == :left ? 1 : title_align == :right ? len - 1 : len / 2
      chars = bold ? BOLD : FAINT
      if Unicode.ambiguous_width == 2
        chars = FALLBACK
        color_seq += "\e[1m" if bold
      end
      horizontal = chars[4]
      line_segments = []
      line_segments << [0, 0, color_seq + chars[0] + horizontal * l + title + horizontal * (len - l) + chars[1]]
      line_segments << [0, 0 + height - 1, color_seq + chars[2] + horizontal * (width - 2) + chars[3]]
      vertical = color_seq + chars[5]
      (1..height - 2).each do |y|
        line_segments << [0, y, vertical] << [width - 1, y, vertical]
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
