module Kafka
  class Producer
    class DeliveryReport
      # Returns a callback to be used when a message is delivered to a broker.
      #
      # This logs the message payload that was delivered.
      def self.callback
        ->(handle : LibRdKafka::KafkaHandle, message : LibRdKafka::Message, opaque : Void*) {
          Log.info { "Message Delivered - #{message.payload.null? ? "(empty message payload)" : String.new(message.payload)}" }
        }
      end
    end
  end
end
