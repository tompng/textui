# frozen_string_literal: true

module Textui
  class Component
    attr_reader :parent
    attr_accessor :clickable
    attr_writer :left, :top

    def left
      @left ||= 0
    end

    def top
      @top ||= 0
    end

    def focusable = false

    def focused? = root&.focused_component == self

    def tick
      children.each(&:tick)
    end

    def key_press(key)
      trigger_event(:key, key)
    end

    def absolute_position
      px, py = @parent&.absolute_position
      [(px || 0) + left, (py || 0) + top]
    end

    def remove
      @parent&.remove_child(self)
    end

    def blur(direction = nil)
      return unless focused?

      root&.move_focus(direction)
    end

    def focus
      root&.focused_component = self if focusable
    end

    def root
      @parent&.root
    end

    def cursor_pos; end

    def draw(x, y, text, z_index: nil, click: @clickable.nil? ? @clickable_by_callbacks : @clickable)
      raise '`draw` can only called from render method' unless @rendered
      @rendered << [x, y, text, z_index, (self if click), click]
    end

    def _render
      @rendered = []
      render
      result = @rendered
      @rendered = nil
      result
    end

    def render
      children.each do |component|
        component._render.each do |x, y, text, z, clickable, data|
          @rendered << [component.left + x, component.top + y, text, z, clickable, data]
        end
      end
    end

    def _set_parent(parent)
      @parent = parent
    end

    def children
      @children || []
    end

    def traverse_child
      children.each do |component|
        yield component
        component.traverse_child { yield _1 }
      end
    end

    def add_child(component)
      (@children ||= []) << component
      component.parent.remove(component) if component.parent && component.parent != self
      component._set_parent(self)
    end

    def remove_child(component)
      @children -= [component]
      component._set_parent(nil)
    end

    def self.define_callbacks(*names)
      names.each do |name|
        class_eval <<~RUBY
          def on_#{name}(&block)
            raise ArgumentError, 'block is required' unless block
            self.on_#{name} = block
          end

          def on_#{name}=(block)
            raise ArgumentError, 'Invalid callback' unless block.nil? || block.is_a?(Proc)
            event_callbacks[:#{name}] = block
            on_update_callbacks
          end
        RUBY
      end
    end

    private def on_update_callbacks
      @clickable_by_callbacks = %i[mouse_up mouse_down mouse_scroll_up mouse_scroll_down].any? { event_callbacks[_1] }
    end

    private def event_callbacks
      @event_callbacks ||= {}
    end

    def trigger_event(name, arg)
      if (callback = event_callbacks[name])
        callback.arity == 0 ? callback.call : callback.call(arg)
      end
    end

    def mouse_up(e) = trigger_event(:mouse_up, e)
    def mouse_down(e) = trigger_event(:mouse_down, e)
    def mouse_scroll_up(e) = trigger_event(:mouse_scroll_up, e)
    def mouse_scroll_down(e) = trigger_event(:mouse_scroll_down, e)

    define_callbacks :mouse_up, :mouse_down, :mouse_scroll_up, :mouse_scroll_down
  end

  class RootContainer < Component
    attr_writer :cursor_pos

    def focused_component=(component)
      current = focused_component
      current.trigger_event(:blur, current) if current && current != component
      component.trigger_event(:focus, component) if component && current != component
      @focused_component = component
      @blured = false
    end

    def focused_component
      @focused_component if @focused_component&.root == self && !@blured && @focused_component.focusable
    end

    def root = self

    def cursor_pos
      pos = focused_component&.cursor_pos
      return unless pos
      if (x, y = focused_component&.cursor_pos)
        ax, ay = focused_component.absolute_position
        return [ax + x, ay + y]
      end
      @cursor_pos
    end

    def move_focus(direction = :next)
      unless direction
        current = focused_component
        current.trigger_event(:blur, current) if current
        @blured = true
        return
      end
      focusable_components = []
      traverse_child do |component|
        focusable_components << component if component == @focused_component || component.focusable
      end
      i = focusable_components.index(@focused_component)
      if i == 0 && focusable_components.size == 1
        @blured = true
        return
      end
      case direction
      in :next
        self.focused_component = focusable_components[((i || -1) + 1) % focusable_components.size]
      in :prev
        self.focused_component = focusable_components[((i || 0) - 1) % focusable_components.size]
      end
      @blured = false
    end

    def key_press(key)
      if focused_component
        focused_component.key_press(key)
      else
        @blured = false
        move_focus(:next) unless focused_component
      end
      trigger_event(:key_press, key)
    end

    define_callbacks :key_press
  end
end
