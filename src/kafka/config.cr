module Kafka
  class Config
    class InvalidConfigException < Exception
      def initialize(@err : String); end

      def message
        "librdkafka error - #{@err}"
      end
    end

    # Returns a librdkafka configuration object with the given properties set.
    #
    # Raises a `Kafka::Config::InvalidConfigException` when setting config fails.
    # Calls the `rd_kafka_conf_new` and `rd_kafka_conf_set` C functions.
    def self.build(properties : Hash(String, String)) : LibRdKafka::ConfHandle
      config = LibRdKafka.conf_new
      errors = properties.map do |key, value|
        error_buffer = uninitialized UInt8[Kafka::MAX_ERR_LEN]
        errstr = error_buffer.to_unsafe
        result = LibRdKafka.conf_set(config, key, value, errstr, error_buffer.size)
        String.new(errstr) unless result == LibRdKafka::OK
      end.compact
      raise InvalidConfigException.new(errors.map(&.to_s).join(". ")) if errors.size > 0

      config
    end
  end
end
