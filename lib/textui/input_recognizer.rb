class Textui::InputRecognizer
  def initialize
    @buf = ''.b
    @bracketed_paste = nil
    @encoding = Encoding.default_external
  end

  ARROWS = { left: 'D', right: 'C', up: 'A', down: 'B', end: 'F', home: 'H' }
  KEYS = {}
  Key = Data.define(:type, :raw)

  ARROWS.each do |type, char|
    KEYS["\e[#{char}"] = type
    KEYS["\eO#{char}"] = type
    KEYS["\e\e[#{char}"] = :"meta_#{type}"
    KEYS["\e\eO#{char}"] = type
    KEYS["\e[1;5#{char}"] = :"ctrl_#{type}"
    KEYS["\e[1;3#{char}"] = :"meta_#{type}"
    KEYS["\e[1;2#{char}"] = :"shift_#{type}"
  end
  KEYS["\x7F"] = :backspace
  KEYS["\e\x7F"] = :meta_backspace
  KEYS["\e[200~"] = :bracketed_paste
  KEYS["\e"] = :escape
  KEYS["\e\e"] = :meta_escape
  KEYS["\x00"] = :ctrl_at
  KEYS["\e\x00"] = :meta_ctrl_at
  ('a'..'z').each do |c|
    KEYS[(c.ord % 32).chr] = :"ctrl_#{c}"
    KEYS["\e#{(c.ord % 32).chr}"] = :"ctrl_#{c}"
    KEYS["\e#{c}"] = :"meta_#{c}"
    KEYS["\e#{c.upcase}"] = :"meta_#{c.upcase}"
  end
  ('0'..'9').each do |c|
    KEYS["\e#{c}"] = :"meta_#{c}"
  end

  def consume(byte)
    if @bracketed_paste
      @bracketed_paste << byte
      if @bracketed_paste.end_with?("\e[201~")
        raw = @bracketed_paste[0...-6].force_encoding(@encoding)
        @bracketed_paste = nil
        return Key.new(type: :bracketed_paste, raw:)
      end
      return
    end

    raw = test(byte)
    return :wait unless raw

    key = KEYS[raw]
    if key == :bracketed_paste
      @bracketed_paste = ''.b
      return
    end

    return Key.new(type: key, raw:) if key

    raw.force_encoding(@encoding)
    Key.new(type: raw.size == 1 ? :key : :unknown, raw:) if raw.valid_encoding?
  end

  def test(byte)
    unless byte
      res = @buf.dup
      @buf.clear
      return res
    end
    @buf << byte
    if @buf.start_with?("\e")
      if @buf !~ /\A(\e\e?|\e\e?\[[\x30-\x3f]*[\x20-\x2f]*|\A\e\e?O)\z/
        s = @buf.dup
        @buf.clear
        s
      end
    else
      s = @buf.dup.force_encoding(@encoding)
      if s.valid_encoding?
        @buf.clear
        s
      end
    end
  end
end

class Textui::Event
  def initialize(input, intr: true, tick:)
    @resized = @resumed = false
    @intr = intr
    @tick = tick
    @input = input
    @winch_trap = Signal.trap(:WINCH) do
      @resized = true
    end
    @winch_trap = Signal.trap(:CONT) do
      @resumed = true
    end
    @input_recognizer = Textui::InputRecognizer.new
  end

  def self.each(input, intr: true, tick:, &)
    print "\e[?2004h" # enable bracketed paste
    event = new(input, intr: intr, tick: tick)
    event.run(&)
  ensure
    print "\e[?2004l" # disable bracketed paste
    event.cleanup
  end

  KEY_TIMEOUT = 0.1

  def run
    @input.raw(intr: @intr) do
      next_tick = Time.now + @tick if @tick
      input_recognizer = Textui::InputRecognizer.new
      input_timeout = nil
      loop do
        next_event, mode = (
          if input_timeout && input_timeout < next_tick
            [input_timeout, :timeout]
          else
            [next_tick, :tick]
          end
        )
        readable = @input.wait_readable([next_event - Time.now, 0].max)
        yield :resize if @resized
        yield :resume if @resumed
        @resized = @resumed = false
        if readable
          res = input_recognizer.consume @input.getbyte
          if res == :wait
            input_timeout = Time.now + KEY_TIMEOUT
          else
            input_timeout = nil
            yield :key, res if res
          end
        elsif mode == :tick
          next_tick = Time.now + @tick
          yield :tick
        else
          res = input_recognizer.consume(nil)
          yield :key, res if res
        end
      end
    end
  end

  def cleanup
    Signal.trap(:WINCH, @winch_trap) if @winch_trap
  end
end
