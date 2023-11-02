module Kafka
  class Consumer < Client
    class Rebalance
      def self.callback
        ->(h : LibKafkaC::KafkaHandle, err : Int32, tpl : LibKafkaC::TopicPartitionList*, opaque : Void*) do
          Log.info { Kafka::Error.new(err).message }
          Log.info { "Topic: #{String.new(tpl.value.elems.value.topic)}, Partition: #{tpl.value.elems.value.partition}" }

          if err == LibKafkaC::RespErrAssignPartitions
            LibKafkaC.assign(h, tpl)
            return
          end
          LibKafkaC.assign(h, nil)
        end
      end
    end
  end
end
