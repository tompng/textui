module Textui
  class Component
    attr_reader :parent
    attr_accessor :clickable

    def tick; end

    def key_press(key); end

    def absolute_position
      px, py = @parent&.absolute_position
      x, y = @parent&.position_of(self)
      [(px || 0) + (x || 0), (py || 0) + (y || 0)]
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

    def cursor_pos
      each_with_position do |component, (cx, cy)|
        if (x, y = component.cursor_pos)
          return [cx + x, cy + y]
        end
      end
    end

    def position_of(component)
      @component_positions[component]
    end

    def add(component, x, y)
      component.parent.remove(component) if component.parent && component.parent != self
      @component_positions[component] = [x, y]
      component._set_parent(self)
    end

    def remove(component)
      @component_positions.delete(component)
      component._set_parent(nil)
    end
  end
end
