require "./kafka/*"

module Kafka
  VERSION     = "0.4.2"
  MAX_ERR_LEN = 160

  Log = ::Log.for("crafka")

  def self.version_info
    "crafka v#{VERSION}, librdkafka v#{librdkafka_version}"
  end

  def self.librdkafka_version
    String.new(LibRdKafka.version_str)
  end

  class KafkaException < Exception
    def initialize(@err : Int32 | String); end

    # If err is an `Int32` call `rd_kafka_err2str` C function to convert to error message, otherwise return err.
    def message
      detailed_message = if @err.is_a?(Int32)
                           String.new(LibRdKafka.err2str(@err.as(Int32)))
                         else
                           @err
                         end
      "librdkafka error - #{detailed_message}"
    end
  end

  class ProducerException < KafkaException
  end

  class ConsumerException < KafkaException
  end
end
