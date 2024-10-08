# frozen_string_literal: true

require_relative 'textui/version'
require_relative 'textui/input_recognizer'
require_relative 'textui/component'
require_relative 'textui/unicode'
require_relative 'textui/screen'
require_relative 'textui/textarea'
require_relative 'textui/box'

module Textui
  @root = Textui::RootContainer.new

  def self.add_child(component)
    @root.add_child(component)
  end

  def self.remove_child(component)
    @root.remove_child(component)
  end

  def self.event_loop(fullscreen:, tick: 0.1)
    screen = Screen.new(fullscreen:)
    screen.render(@root)
    Textui::EventRunner.each($stdin, tick:) do |type, data|
      case type
      when :mouse_down, :mouse_up, :mouse_scroll_down, :mouse_scroll_up
        x, y, component, data = screen.clickable_at(data[0], data[1])
        if component && component.respond_to?(type)
          cx, cy = component.absolute_position
          event = MouseEvent.new(type, x - cx, y - cy, x, y, data)
          component.send(type, event)
        end
      when :key
        if data.type == :ctrl_l
          screen.reset_screen
        else
          @root.key_press(data)
        end
      when :tick
        @root.tick
      when :resume
        $stdin.raw!(intr: true)
        screen.resume
      when :resize
        screen.resize
      end
      yield type, data if block_given?
      screen.render(@root)
    end
  ensure
    screen.cleanup
  end
end
