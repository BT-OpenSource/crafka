module Kafka
  class Consumer
    class Rebalance
      # Returns a callback to be used when partitions are assigned/unassigned.
      #
      # This will log the assignment event with the topic name and partition number.
      # Calls the `rd_kafka_assign` C function.
      def self.callback
        ->(h : LibRdKafka::KafkaHandle, err : Int32, tpl : LibRdKafka::TopicPartitionList*, opaque : Void*) do
          Log.info { RdKafka::Error.new(err).message }

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
