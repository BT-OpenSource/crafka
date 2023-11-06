module RdKafka
  struct Error
    getter code

    def initialize(@code : Int32); end

    # Calls `rd_kafka_err2str` C function to convert error code to message.
    def message
      pointer = LibRdKafka.err2str(code)
      String.new(pointer)
    end
  end
end
