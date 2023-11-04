require "log"
require "./consumer/*"

module Kafka
  class Consumer < Client
    ERRLEN = 128

    def initialize(config : Hash(String, String))
      conf = Kafka::Config.build(config)
      LibKafkaC.set_rebalance_cb(conf, Rebalance.callback)

      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_CONSUMER, conf, out errstr, 512)
      raise "Kafka: Unable to create new producer: #{errstr}" if @handle == 0_u64
      @running = true
      LibKafkaC.poll_set_consumer(@handle)
    end

    def subscribe(*topics) : Error?
      tpl = LibKafkaC.topic_partition_list_new(topics.size)
      topics.each do |topic|
        LibKafkaC.topic_partition_list_add(tpl, topic, -1)
      end
      err = LibKafkaC.subscribe(@handle, tpl)
      if err != 0
        LibKafkaC.topic_partition_list_destroy(tpl)
        return Kafka::Error.new(err)
      end
      LibKafkaC.topic_partition_list_destroy(tpl)
    end

    def poll(timeout_ms : Int32) : Message?
      message_ptr = LibKafkaC.consumer_poll(@handle, timeout_ms)
      return if message_ptr.null?

      message = Message.new(message_ptr.value)
      LibKafkaC.message_destroy(message_ptr)
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
      LibKafkaC.consumer_close(@handle)
    end
  end
end
