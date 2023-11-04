module Kafka
  class Consumer
    class Rebalance
      def self.callback
        ->(h : LibRdKafka::KafkaHandle, err : Int32, tpl : LibRdKafka::TopicPartitionList*, opaque : Void*) do
          Log.info { RdKafka::Error.new(err).message }
          Log.info { "Topic: #{String.new(tpl.value.elems.value.topic)}, Partition: #{tpl.value.elems.value.partition}" }

          if err == LibRdKafka::RespErrAssignPartitions
            LibRdKafka.assign(h, tpl)
            return
          end
          LibRdKafka.assign(h, nil)
        end
      end
    end
  end
end
