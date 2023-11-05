require "./kafka/*"

module Kafka
  VERSION     = "0.1.0"
  MAX_ERR_LEN = 160

  class KafkaException < Exception
    def initialize(@err : Int32 | String); end

    def message
      detailed_message = if @err.is_a?(Int32)
                           String.new(LibRdKafka.err2str(@err.as(Int32)))
                         else
                           @err
                         end
      "librdkafka error - #{detailed_message}"
    end
  end

  class KafkaProducerException < KafkaException
  end

  class ConsumerException < KafkaException
  end
end
