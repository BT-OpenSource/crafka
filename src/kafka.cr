require "./kafka/*"

module Kafka
  VERSION = "0.1.0"

  class KafkaException < Exception
    def initialize(@err : Int32)
    end

    def message
      String.new(LibRdKafka.err2str(@err))
    end
  end

  class KafkaProducerException < KafkaException
  end

  class KafkaConsumerException < KafkaException
  end
end
