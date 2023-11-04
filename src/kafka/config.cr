module Kafka
  class Config
    struct Error
      property code : Int32
      property property_name : String

      def initialize(@property_name, @code); end

      def to_s
        "#{LibRdKafka::ConfErrorMsg[code]}: #{property_name}"
      end
    end

    def self.build(properties : Hash(String, String)) : LibRdKafka::ConfHandle
      config = LibRdKafka.conf_new
      errors = properties.map do |key, value|
        result = LibRdKafka.conf_set(config, key, value, nil, 128)
        Kafka::Config::Error.new(key, result) unless result == LibRdKafka::Conf::OK.value
      end.compact
      raise "Failed to load config - #{errors.map(&.to_s).join(". ")}" if errors.size > 0

      config
    end
  end
end
