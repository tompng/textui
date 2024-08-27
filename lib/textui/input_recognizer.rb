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
      return :wait
    end

    raw = test(byte)
    return :wait unless raw

    key = KEYS[raw]
    if key == :bracketed_paste
      @bracketed_paste = ''.b
      return :wait
    end

    return Key.new(type: key, raw:) if key

    raw.force_encoding(@encoding)
    Key.new(type: raw.size == 1 ? :key : :unknown, raw:) if raw.valid_encoding?
  end

  def each_key(input, intr: true)
    input.raw(intr:) do
      loop do
        key = consume(input.getbyte)
        if key == :wait
          if input.wait_readable(0.1)
            redo
          else
            consume(nil)
          end
        else
          yield key
        end
      end
    end
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
