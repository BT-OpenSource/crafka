require "log"
require "./consumer/*"

module Kafka
  class Consumer
    ERRLEN = 128

    def initialize(config : Hash(String, String))
      conf = Kafka::Config.build(config)
      LibRdKafka.set_rebalance_cb(conf, Rebalance.callback)

      @handle = LibRdKafka.kafka_new(LibRdKafka::TYPE_CONSUMER, conf, out errstr, 512)
      raise "Kafka: Unable to create new producer: #{errstr}" if @handle == 0_u64
      @running = true
      LibRdKafka.poll_set_consumer(@handle)
    end

    def subscribe(*topics) : RdKafka::Error?
      tpl = LibRdKafka.topic_partition_list_new(topics.size)
      topics.each do |topic|
        LibRdKafka.topic_partition_list_add(tpl, topic, -1)
      end
      err = LibRdKafka.subscribe(@handle, tpl)
      if err != 0
        LibRdKafka.topic_partition_list_destroy(tpl)
        return RdKafka::Error.new(err)
      end
      LibRdKafka.topic_partition_list_destroy(tpl)
    end

    def poll(timeout_ms : Int32) : Message?
      message_ptr = LibRdKafka.consumer_poll(@handle, timeout_ms)
      return if message_ptr.null?

      message = Message.new(message_ptr.value)
      LibRdKafka.message_destroy(message_ptr)
      message
    end

    def each(timeout = 250)
      loop do
        Fiber.yield
        resp = poll(timeout)
        next if resp.nil?
        yield resp
        break unless @running
      end
    end

    def close
      @running = false
      LibRdKafka.consumer_close(@handle)
    end
  end
end
