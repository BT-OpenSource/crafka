module Kafka
  class Producer
    class Statistics
      # Returns a callback to be used every statistics.interval.ms (configured separately)
      #
      # The callback writes the statistics to the given file path.
      def self.callback(file_path : String)
        # can't pass file_path into a proc called by C: "passing a closure to C is not allowed"
        @@file_path = file_path
        ->(handle : LibRdKafka::KafkaHandle, json : UInt8*, json_length : LibC::SizeT, opaque : Void*) {
          File.write("#{directory}/librdkafka_stats.json", String.new(json))
        }
      end

      def self.directory
        @@file_path
      end
    end
  end
end
