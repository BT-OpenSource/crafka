module Kafka
  class Producer
    class DeliveryReport
      # Returns a callback to be used when a message is delivered to a broker.
      #
      # This logs the message payload that was delivered. The message arrives
      # by pointer (see the conf_set_dr_msg_cb binding); the payload is not
      # NUL-terminated, so the string is built with the message length. When
      # err is set, librdkafka reuses the payload field for the error string.
      def self.callback
        ->(handle : LibRdKafka::KafkaHandle, message : LibRdKafka::Message*, opaque : Void*) {
          msg = message.value
          if msg.err != 0
            Log.error { "Message Delivery Failed - #{msg.payload.null? ? "(no error detail)" : String.new(msg.payload, msg.len)}" }
          else
            Log.info { "Message Delivered - #{msg.payload.null? ? "(empty message payload)" : String.new(msg.payload, msg.len)}" }
          end
        }
      end
    end
  end
end
