require "./config.cr"

module Kafka
  class Consumer
    def initialize(@conf : Config)
      @closing = false
      @pErrStr = LibC.malloc(ERRLEN).as(UInt8*)
      @topic_conf = LibKafkaC.topic_conf_new();
      err = LibKafkaC.topic_conf_set(@topic_conf, "offset.store.method", "broker", @pErrStr, ERRLEN)
      raise "Error setting topic conf offset.store.method #{String.new @pErrStr}" if err != LibKafkaC::OK
      # Set default topic config for pattern-matched topics.
      LibKafkaC.conf_set_default_topic_conf(conf, @topic_conf);
      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_CONSUMER, conf, @pErrStr, ERRLEN)
      raise "Kafka: Unable to create new consumer" if @handle.not_nil!.address == 0_u64
      @queue  = LibKafkaC.queue_get_consumer(@handle)
	    @queue = LibKafkaC.queue_get_main(@handle) if @queue.null?
    end

    def poll_queue(timeout)
      rkev = LibKafkaC.queue_poll(@queue, timeout)
      evtype = LibKafkaC.event_type(rkev)
      case evtype
      when LibKafkaC::Event::NONE
      when LibKafkaC::Event::FETCH
        msg_ptr = LibKafkaC.event_message_next(rkev)
        msg = msg_ptr.value
        msg.timestamp = LibKafkaC.message_timestamp(msg_ptr, out ts_type)
        msg
      when LibKafkaC::Event::REBALANCE
        err = LibKafkaC.event_error(rkev)
        puts "INFO: Rebalance #{err}"
      when LibKafkaC::Event::OFFSET_COMMIT
        puts "INFO: Offset commit"
        err = LibKafkaC.event_error(rkev)
        offsets = LibKafkaC.event_topic_partition_list(rkev)
        puts err, offsets
      when LibKafkaC::Event::ERROR
        err = LibKafkaC.event_error(rkev)
        puts "ERROR: [#{err}] #{String.new(LibKafkaC.event_error_string(rkev))}" unless err == -191
      else
        puts "Unknown type #{evtype}"
      end
    end
    # Subscribe to one or more topics letting Kafka handle partition assignments.
    #
    # @param topics [Array<String>] One or more topic names
    #
    # @raise [RdkafkaError] When subscribing fails
    #
    # @return [nil]
    def subscribe(topics : Array(String))
      # Create topic partition list with topics and no partition set
      puts "Subscribing to topics #{topics}"
      tpl = LibKafkaC.topic_partition_list_new(topics.size)
      topics.each do |topic|
        puts "Adding #{topic}"
        LibKafkaC.topic_partition_list_add(tpl, topic, -1)
      end
      # Subscribe to topic partition list and check this was successful
      response = LibKafkaC.subscribe(@handle, tpl)
      if response != 0
        raise "Error subscribing to '#{topics.join(", ")}'"
      end
    ensure
      # Clean up the topic partition list
      LibKafkaC.topic_partition_list_destroy(tpl)
    end

    # Poll for the next message on one of the subscribed topics
    #
    # @param timeout_ms [Integer] Timeout of this poll
    #
    # @raise [RdkafkaError] When polling fails
    #
    # @return [Message, nil] A message or nil if there was no new message within the timeout
    def poll(timeout_ms : Int32) : Message?
      message_ptr = LibKafkaC.consumer_poll(@handle, timeout_ms)
      message_ptr.try do |msg|
        Message.new msg unless msg.null?
      end
    end


    # Poll for new messages and yield for each received one. Iteration
    # will end when the consumer is closed.
    #
    # @raise [RdkafkaError] When polling fails
    #
    # @yieldparam message [Message] Received message
    #
    # @return [nil]
    def each(&block)
      loop do
        message = poll(250)
        if message
          yield message
        else
          if @closing
            break
          else
            next
          end
        end
      end
    end

    def close()
      @closing = false
      LibKafkaC.consumer_close(@handle)
    end

    # :nodoc:
    def finalize()
      begin
        LibC.free(@pErrStr)
        LibKafkaC.kafka_destroy(@handle) if @handle
      end
    end
  end
end
