module Textui
  class Component
    attr_accessor :clickable
    def tick; end

    def key_press(key); end

    def cursor_pos; end

    def render; end
  end
end
