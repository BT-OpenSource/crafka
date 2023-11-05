require "log"
require "./consumer/*"

module Kafka
  class Consumer
    getter handle

    def initialize(config : Hash(String, String))
      conf = Kafka::Config.build(config)
      LibRdKafka.set_rebalance_cb(conf, Rebalance.callback)

      error_buffer = uninitialized UInt8[Kafka::MAX_ERR_LEN]
      errstr = error_buffer.to_unsafe
      @handle = LibRdKafka.kafka_new(LibRdKafka::TYPE_CONSUMER, conf, errstr, error_buffer.size)
      raise ConsumerException.new(String.new(errstr)) if @handle.null?

      @running = true
      LibRdKafka.poll_set_consumer(@handle)
    end

    def subscribe(*topics)
      tpl = LibRdKafka.topic_partition_list_new(topics.size)
      topics.each do |topic|
        LibRdKafka.topic_partition_list_add(tpl, topic, -1)
      end
      err = LibRdKafka.subscribe(@handle, tpl)
      raise ConsumerException.new(err) if err != 0
    ensure
      LibRdKafka.topic_partition_list_destroy(tpl) if tpl
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
      LibRdKafka.kafka_destroy(@handle)
    end
  end
end
