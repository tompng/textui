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
    @key = key
  end


  def tick
    @cnt += 1
  end

  def render
    (0..20).map do |y|
      [(@cnt+y)%7, y % 10, "\e[#{y<10 ? 41 : 42}m#{@cnt}helloworld y:#{y} #{@cnt}", y]
    end + [[4, 4, [@key].inspect.inspect, 99]]
  end
end

def example
  screen = Textui::Screen.new
  component = RootComponent.new
  screen.render(component)

  Textui::Event.each($stdin, tick: 0.1) do |type, data|
    case type
    when :key
      component.key_press(data)
    when :tick
      component.tick
    when :resize, :resume
      screen.resize
    end
    screen.render(component)
  end
rescue Interrupt
ensure
  screen.cleanup
end
