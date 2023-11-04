require "./lib_rdkafka.cr"

module Kafka
  struct Message
    @err : Error?
    @offset : Int64?
    @timestamp : Int64?
    getter err, offset, key, payload, partition, timestamp

    def initialize(@payload : Bytes, @key : Bytes)
      @partition = LibKafkaC::PARTITION_UNASSIGNED
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
