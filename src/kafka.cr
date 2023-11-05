require "./kafka/*"

module Kafka
  VERSION     = "0.1.0"
  MAX_ERR_LEN = 160

  class KafkaException < Exception
    def initialize(@err : Int32)
    end

    def message
      "librdkafka error - #{String.new(LibRdKafka.err2str(@err))}"
    end
  end

  class KafkaProducerException < KafkaException
  end

  class ConsumerException < KafkaException
  end
end
