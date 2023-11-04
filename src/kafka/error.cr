module Kafka
  struct Error
    getter code

    def initialize(@code : Int32); end

    def message
      pointer = LibKafkaC.err2str(code)
      String.new(pointer)
    end
  end
end
