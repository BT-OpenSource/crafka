module Kafka
  class Config
    def self.build(properties : Hash(String, String)) : LibRdKafka::ConfHandle
      config = LibRdKafka.conf_new
      errors = properties.map do |key, value|
        error_buffer = uninitialized UInt8[Kafka::MAX_ERR_LEN]
        errstr = error_buffer.to_unsafe
        result = LibRdKafka.conf_set(config, key, value, errstr, error_buffer.size)
        String.new(errstr) unless result == LibRdKafka::Conf::OK.value
      end.compact
      raise "Failed to load config - #{errors.map(&.to_s).join(". ")}" if errors.size > 0

      config
    end
  end
end
