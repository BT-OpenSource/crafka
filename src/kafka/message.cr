require "./librdkafka.cr"
require "./rdkafka/*"

module Kafka
  struct Message
    @err : RdKafka::Error?
    @offset : Int64?
    @timestamp : Int64?
    @partition = LibRdKafka::PARTITION_UNASSIGNED
    @rkt : LibRdKafka::Topic
    getter err, offset, key, payload, partition, timestamp

    def initialize(msg : LibRdKafka::Message)
      if msg.err != LibRdKafka::OK
        @err = RdKafka::Error.new(msg.err)
      end
      @payload = Slice(UInt8).new(msg.len)
      @payload.copy_from(msg.payload, msg.len)
      @key = Slice(UInt8).new(msg.key_len)
      @key.copy_from(msg.key, msg.key_len)
      @partition = msg.partition
      @offset = msg.offset
      @timestamp = msg.timestamp
      @rkt = msg.rkt
    end

    def topic
      LibRdKafka.topic_name(@rkt)
    end
  end
end
