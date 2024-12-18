require "log"
require "./consumer/*"

module Kafka
  class Consumer
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

    # Subscribe to topics using balanced consumer groups.
    #
    # Supports regex - start topic with '^'. For example:
    # ```
    # consumer.subcribe("^foo") # will match any topics that starts with foo.
    # ```
    #
    # Raises a `Kafka::ConsumerException` when the subscribe fails.
    #
    # Calls the `rd_kafka_subscribe` C function.
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

    # Poll the consumer for messages or events.
    #
    # Calls the `rd_kafka_consumer_poll` C function.
    def poll(timeout_ms : Int32, raise_on_error : Bool = true) : Message?
      message_ptr = LibRdKafka.consumer_poll(@handle, timeout_ms)
      return if message_ptr.null?

      message = Message.new(message_ptr.value)
      LibRdKafka.message_destroy(message_ptr)
      if raise_on_error && (err = message.err)
        raise ConsumerException.new(err.message)
      end

      message
    end

    # Loops indefinitely calling `#poll` at the given interval `timeout`.
    #
    # At the beginning of each loop, `Fiber.yield` is called allow other Fibers to run.
    def each(timeout = 250, raise_on_error = true, &)
      loop do
        Fiber.yield
        resp = poll(timeout, raise_on_error)
        next if resp.nil?
        yield resp
        break unless @running
      end
    end

    # Close the consumer and destroy the Kafka handle.
    #
    # Calls the `rd_kafka_consumer_close` and `rd_kafka_destroy` C functions.
    def close
      @running = false
      LibRdKafka.consumer_close(@handle)
      LibRdKafka.kafka_destroy(@handle)
    end
  end
end
