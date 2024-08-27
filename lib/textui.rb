# frozen_string_literal: true

require_relative 'textui/version'
require_relative 'textui/input_recognizer'
require_relative 'textui/unicode'
require_relative 'textui/renderer'

module Textui
  class Error < StandardError; end
  # Your code goes here...
end
class RootComponent 
  def cursor_pos
    [rand(5..15), rand(2..4)]
  end

  def render
    @cnt ||= 0
    @cnt += 1
    (0..20).map do |y|
      [(@cnt+y)%5 + rand(20), y % 10, "\e[#{y<10 ? 41 : 42}mhelloworld y:#{y} #{@cnt}", y]
    end
  end
end

def example
  renderer = Textui::Renderer.new
  renderer.root = RootComponent.new
  10.times do
    renderer.render
    sleep 0.1
  end
  renderer.terminate
end
