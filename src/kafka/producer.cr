require "./lib_rdkafka.cr"
require "./config.cr"

module Kafka

  # represents a kafka producer
  class Producer

    # creates a new kafka handle using provided config.
    # Throws exception on error
    def initialize(conf : Config)
      @polling = false
      @keep_running = true
      @pErrStr = LibC.malloc(ERRLEN).as(UInt8*)
      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_PRODUCER, conf, @pErrStr, ERRLEN)
      raise "Kafka: Unable to create new producer" if @handle == 0_u64
    end

    # Set the topic to use for *produce()* calls.
    # Raises exception on error.
    def set_topic(name : String)
      @topic = LibKafkaC.topic_new @handle, name, nil
      raise "Kafka: unable to allocate topic instance #{name}" if @topic == 0_u64
    end

    # enqueues *msg*
    # Will start internal polling fiber, if not already started.
    # returns true on success.  Raises exception otherwise
    def produce(msg : String, partition : Int32 = LibKafkaC::PARTITION_UNASSIGNED, key : String? = nil, flags : Int32 = LibKafkaC::MSG_FLAG_COPY )

      raise "No topic set" unless @topic
      part = partition || LibKafkaC::PARTITION_UNASSIGNED

      res = LibKafkaC.produce(@topic, part, flags, msg.to_unsafe, msg.size,
              key, (key.nil? ? 0 : key.size), nil)
      raise "Failed to enqueue message" if res == -1

      start_polling unless @polling

      return true
    end

    # :nodoc:
    private def start_polling()
      return if @polling

      spawn do

        @polling = true

        while @keep_running

          LibKafkaC.poll(@handle, 500)
        end

        @polling = false
      end

    end

    # Calls *flush(1000)* and will stop polling fiber, if running.
    def stop()
      flush(1000)
      @keep_running = false
    end

    def flush(timeout_ms : Int32)
      LibKafkaC.flush(@handle, timeout_ms)
    end

    # returns true if polling fiber is running
    def polling() : Bool
      @polling
    end

    # :nodoc:
    def finalize()
      begin
        LibC.free(@pErrStr)

        LibKafkaC.topic_destroy(@topic) if @topic

        LibKafkaC.kafka_destroy(@handle) if @handle
      end
    end

    # :nodoc:
    def to_unsafe
      return @handle
    end

  end

end
