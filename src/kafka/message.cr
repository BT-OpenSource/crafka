require "./lib_rdkafka.cr"


module Kafka

  class TopicPartition
    
  end

  class Message

    def initialize(@msg : LibKafkaC::Message*)
    end

    def payload : Bytes
      tmp = @msg.value
      Bytes.new(tmp.payload, tmp.len)
    end

    def key : Bytes
      tmp = @msg.value
      Bytes.new(tmp.key, tmp.key_len)
    end

    def finalize()
      LibKafkaC.message_destroy(@msg)
    end
  end


  class OffsetCommit
    def self.from(ev : LibKafkaC::QueueEvent) : OffsetCommit
      err = LibKafkaC.event_error(ev)
      offsets = LibKafkaC.event_topic_partition_list(ev)
      if err != LibKafkaC::RD_KAFKA_RESP_ERR_NO_ERROR
      else
      end

      err
    end

    def initialize
    end
  end
end

