module Textui
  class Component
    attr_reader :parent
    attr_accessor :clickable

    def focusable = false

    def focused? = root&.focused_component == self

    def tick; end

    def key_press(key); end

    def absolute_position
      px, py = @parent&.absolute_position
      x, y = @parent&.position_of(self)
      [(px || 0) + (x || 0), (py || 0) + (y || 0)]
    end

    def remove
      @parent&.remove_child(self)
    end

    def move(x, y)
      @parent&.move_child(self, x, y)
    end

    def focus
      root&.focused_component = self if focusable
    end

    def root
      @parent&.root
    end

    def cursor_pos; end

    def draw(x, y, text, z_index: nil, clickable: @clickable)
      @rendered << [x, y, text, z_index, (self if clickable)]
    end

    def _render
      @rendered = []
      render
      @previous_rendered = @rendered
    end

    def render_previous
      @rendered = @previous_rendered
    end

    def render; end

    def _set_parent(parent)
      @parent = parent
    end
  end

  class Container < Component
    def initialize
      super
      @component_positions = {}
    end

    def components
      @component_positions.keys
    end

    def each_with_position
      @component_positions.each { yield _1, _2 }
    end

    def tick
      components.each(&:tick)
    end

    def key_press(key)
      components.each { _1.key_press(key) }
    end

    def render
      @component_positions.flat_map do |component, (cx, cy)|
        component._render.map do |x, y, text, z, clickable|
          @rendered << [x + cx, y + cy, text, z, clickable]
        end
      end
    end

    def traverse
      components.each do |component|
        yield component
        component.traverse { yield _1 } if component.is_a?(Container)
      end
    end

    def position_of(component)
      @component_positions[component]
    end

    def add_child(component, x, y)
      component.parent.remove(component) if component.parent && component.parent != self
      @component_positions[component] = [x, y]
      component._set_parent(self)
    end

    def move_child(component, x, y)
      raise 'Parent mismatch' if component.parent != self
      @component_positions[component] = [x, y]
    end

    def remove_child(component)
      @component_positions.delete(component)
      component._set_parent(nil)
    end
  end

  class RootContainer < Container
    def focused_component=(component)
      @focused_component = component
    end

    def focused_component
      @focused_component if @focused_component&.root == self
    end

    def root() = self

    def cursor_pos
      pos = focused_component&.cursor_pos
      return unless pos
      if (x, y = focused_component&.cursor_pos)
        ax, ay = focused_component.absolute_position
        [ax + x, ay + y]
      end
    end

    def move_focus(prev_focus, direction = :next)
      focusable_components = []
      traverse do |component|
        focusable_components << component if component.focusable
      end
      i = focusable_components.index(prev_focus)
      case direction
      in :next
        self.focused_component = focusable_components[((i || -1) + 1) % focusable_components.size]
      in :prev
        self.focused_component = focusable_components[((i || 0) - 1) % focusable_components.size]
      end
    end

    def key_press(key)
      if focused_component
        focused_component.key_press(key)
      else
        move_focus(nil, :next)
      end
    end
  end
end
