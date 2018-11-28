require "./lib_rdkafka.cr"


module Kafka

  struct Error
    getter error_code
    def initialize(@error_code : Int32)
    end

    def message
      if p = LibKafkaC.err2str(@error_code)
        String.new(p)
      else
        ""
      end
    end
  end

  struct Message
    @err : Error?
    @offset : Int64?
    @timestamp : Int64?
    getter err, offset, key, payload, partition, timestamp

    def initialize(@payload : Bytes, @key : Bytes)
      @partition = LibKafkaC::PARTITION_UNASSIGNED
      # @timestamp = -1
      # @offset = -1
    end

    def initialize(msg : LibKafkaC::Message)
      if msg.err != LibKafkaC::OK
        @err = Error.new(msg.err)
      end
      @payload = Slice(UInt8).new(msg.len)
      @payload.copy_from(msg.payload, msg.len)
      @key = Slice(UInt8).new(msg.key_len)
      @key.copy_from(msg.key, msg.key_len)
      @partition = msg.partition
      @offset = msg.offset
      @timestamp = msg.timestamp
    end
  end

end
