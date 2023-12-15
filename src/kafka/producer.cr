require "./librdkafka.cr"
require "./producer/*"

module Kafka
  class Producer
    DEFAULT_POLL_INTERVAL_SECONDS = 5

    def initialize(config : Hash(String, String), stats_path = "", poll_interval = DEFAULT_POLL_INTERVAL_SECONDS)
      conf = Kafka::Config.build(config)
      LibRdKafka.conf_set_dr_msg_cb(conf, DeliveryReport.callback)
      LibRdKafka.conf_set_stats_cb(conf, Statistics.callback(stats_path)) unless stats_path.empty?

      @auto_poll = poll_interval != 0
      @poll_interval = poll_interval
      @last_poll_time = Time.utc.to_unix

      error_buffer = uninitialized UInt8[Kafka::MAX_ERR_LEN]
      errstr = error_buffer.to_unsafe
      @handle = LibRdKafka.kafka_new(LibRdKafka::TYPE_PRODUCER, conf, errstr, error_buffer.size)
      raise ProducerException.new(String.new(errstr)) if @handle.null?
    end

    # Produce and send a single message to broker.
    #
    # Raises a `Kafka::ProducerException` when produce fails.
    # Calls the `rd_kafka_producev` C function.
    def produce(topic : String, payload : Bytes)
      err = LibRdKafka.producev(
        @handle,
        LibRdKafka::VTYPE::TOPIC, topic,
        LibRdKafka::VTYPE::VALUE, payload, payload.size,
        LibRdKafka::VTYPE::END
      )
      raise ProducerException.new(err) if err != LibRdKafka::OK

      auto_poll
    end

    # :ditto:
    def produce(topic : String, key : Bytes, payload : Bytes)
      err = LibRdKafka.producev(
        @handle,
        LibRdKafka::VTYPE::TOPIC, topic,
        LibRdKafka::VTYPE::VALUE, payload, payload.size,
        LibRdKafka::VTYPE::KEY, key, key.size,
        LibRdKafka::VTYPE::END
      )
      raise ProducerException.new(err) if err != LibRdKafka::OK

      auto_poll
    end

    # :ditto:
    def produce(topic : String, key : Bytes, payload : Bytes, timestamp : Int64)
      err = LibRdKafka.producev(
        @handle,
        LibRdKafka::VTYPE::TOPIC, topic,
        LibRdKafka::VTYPE::VALUE, payload, payload.size,
        LibRdKafka::VTYPE::KEY, key, key.size,
        LibRdKafka::VTYPE::TIMESTAMP, timestamp,
        LibRdKafka::VTYPE::END
      )
      raise ProducerException.new(err) if err != LibRdKafka::OK

      auto_poll
    end

    # Produce and send a single message to broker.
    #
    # Raises a `Kafka::ProducerException` when produce fails.
    # Calls the `rd_kafka_produce` C function.
    def produce(topic : String, msg : Message)
      topic_struct = LibRdKafka.topic_new(@handle, topic, nil)
      partition = LibRdKafka::PARTITION_UNASSIGNED
      flags = LibRdKafka::MSG_FLAG_COPY
      err = LibRdKafka.produce(topic_struct, partition, flags, msg.payload, msg.payload.size,
        msg.key, msg.key.size, nil)
      raise ProducerException.new(err) if err != LibRdKafka::OK

      auto_poll
    ensure
      LibRdKafka.topic_destroy(topic_struct)
    end

    # Produce and send multiple messages to broker.
    #
    # Raises a `Kafka::ProducerException` when produce fails.
    # Calls the `rd_kafka_produce` C function.
    def produce_batch(topic : String, batch : Array({key: Array(UInt8), msg: Array(UInt8)}))
      topic_struct = LibRdKafka.topic_new(@handle, topic, nil)
      partition = LibRdKafka::PARTITION_UNASSIGNED
      flags = LibRdKafka::MSG_FLAG_COPY
      batch.each do |t|
        err = LibRdKafka.produce(topic_struct, partition, flags, t[:msg], t[:msg].size,
          t[:key], t[:key].size, nil)
        raise ProducerException.new(err) if err != LibRdKafka::OK
      end
      auto_poll
    ensure
      LibRdKafka.topic_destroy(topic_struct)
    end

    # Polls the Kafka handle for events
    #
    # An application should make sure to call #poll at regular
    # intervals to serve any queued callbacks waiting to be called.
    def poll(timeout = 500)
      LibRdKafka.poll(@handle, timeout)
    end

    # Wait until all outstanding produce requests, et.al, are completed.
    # This should typically be done prior to destroying a producer instance
    # to make sure all queued and in-flight produce requests are completed
    # before terminating.
    #
    # Calls the `rd_kafka_flush` C function.
    def flush(timeout = 1000)
      LibRdKafka.flush(@handle, timeout)
    end

    # Destroy the Kafka handle.
    #
    # Calls the `rd_kafka_destroy` C function.
    def finalize
      LibRdKafka.kafka_destroy(@handle)
    end

    private def auto_poll
      return unless @auto_poll && (Time.utc.to_unix - @last_poll_time) > @poll_interval

      poll
      @last_poll_time = Time.utc.to_unix
    end
  end
end
