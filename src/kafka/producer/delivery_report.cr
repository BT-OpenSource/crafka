module Kafka
  class Producer
    class DeliveryReport
      def self.callback
        ->(handle : LibRdKafka::KafkaHandle, message : LibRdKafka::Message, opaque : Void*) {
          Log.info { "Message Delivered - #{String.new(message.payload)}" }
        }
      end
    end
  end
end
