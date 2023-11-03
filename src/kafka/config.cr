module Kafka
  class Config
    struct Error
      property code : Int32
      property property_name : String

      def initialize(@property_name, @code); end

      def to_s
        "#{LibKafkaC::ConfErrorMsg[code]}: #{property_name}"
      end
    end

    def self.set(properties : Hash(String, String)) : LibKafkaC::ConfHandle
      config = LibKafkaC.conf_new
      errors = properties.map do |key, value|
        result = LibKafkaC.conf_set(config, key, value, nil, 128)
        Kafka::Config::Error.new(key, result) unless result == LibKafkaC::Conf::OK.value
      end.compact
      raise "Failed to load config - #{errors.map(&.to_s).join(". ")}" if errors.size > 0

      config
    end
  end
end
