# frozen_string_literal: true

require_relative 'textui/version'
require_relative 'textui/input_recognizer'
require_relative 'textui/unicode'
require_relative 'textui/screen'

module Textui
  class Error < StandardError; end
  # Your code goes here...
end
class RootComponent 
  def initialize
    @cnt = 0
  end

  def cursor_pos
    [rand(0..3), rand(0..3)]
  end

  def key_press(key)
    @cnt += 1
  end

  def render
    (0..20).map do |y|
      [(@cnt+y)%7, y % 10, "\e[#{y<10 ? 41 : 42}mhelloworld y:#{y} #{@cnt}", y]
    end
  end
end

def example
  screen = Textui::Screen.new
  recognizer = Textui::InputRecognizer.new
  component = RootComponent.new
  screen.render(component)
  recognizer.each_key $stdin do |key|
    component.key_press(key)
    screen.render(component)
  end
  screen.cleanup
end
