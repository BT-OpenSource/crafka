module RdKafka
  struct Error
    getter code

    def initialize(@code : Int32); end

    def message
      pointer = LibRdKafka.err2str(code)
      String.new(pointer)
    end
  end
end
