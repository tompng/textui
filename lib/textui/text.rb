require_relative 'unicode'
require_relative 'component'

module Textui
  class Text < Component
    attr_reader :content, :width, :color_seq
    def initialize(content, width: nil, left: 0, top: 0, color_seq: '')
      @content, @left, @top, @width, @color_seq = content, left, top, width, color_seq
      reconstruct
    end

    def content=(content)
      @content = content
      reconstruct
    end

    def width=(width)
      @width = width
      reconstruct
    end

    def color_seq=(color_seq)
      @color_seq = color_seq
      reconstruct
    end

    def reconstruct
      @lines = @width ? Unicode.wrap_colored_text(@content, @width) : @content.split("\n", -1)
    end

    def render
      @lines.each_with_index do |text, y|
        draw(0, y, text)
      end
    end
  end
end
