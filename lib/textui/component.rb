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
      children.each { _1.key_press(key) }
    end

    def absolute_position
      px, py = @parent&.absolute_position
      [(px || 0) + left, (py || 0) + top]
    end

    def remove
      @parent&.remove_child(self)
    end

    def blur(direction = nil)
      root&.move_focus(direction) if focused?
    end

    def focus
      root&.focused_component = self if focusable
    end

    def root
      @parent&.root
    end

    def cursor_pos; end

    def draw(x, y, text, z_index: nil, click: @clickable)
      @rendered << [x, y, text, z_index, (self if click), click]
    end

    def _render
      @rendered = []
      render
      @previous_rendered = @rendered
    end

    def render_previous
      @rendered = @previous_rendered
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
  end

  class RootContainer < Component
    def focused_component=(component)
      @focused_component = component
      @blured = false
    end

    def focused_component
      @focused_component if @focused_component&.root == self && !@blured
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

    def move_focus(direction = :next)
      unless direction
        @blured = true
        return
      end
      focusable_components = []
      traverse_child do |component|
        focusable_components << component if component.focusable
      end
      i = focusable_components.index(@focused_component)
      case direction
      in :next
        @focused_component = focusable_components[((i || -1) + 1) % focusable_components.size]
      in :prev
        @focused_component = focusable_components[((i || 0) - 1) % focusable_components.size]
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
    end
  end
end
