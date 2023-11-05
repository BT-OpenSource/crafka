require "./librdkafka.cr"

module Kafka
  class Producer
    def initialize(config : Hash(String, String))
      conf = Kafka::Config.build(config)
      cb = ->(h : LibRdKafka::KafkaHandle, x : Void*, y : Void*) {
        Log.info { "CB #{x}" }
      }
      LibRdKafka.conf_set_dr_msg_cb(conf, cb)

      error_buffer = uninitialized UInt8[Kafka::MAX_ERR_LEN]
      errstr = error_buffer.to_unsafe
      @handle = LibRdKafka.kafka_new(LibRdKafka::TYPE_PRODUCER, conf, errstr, error_buffer.size)
      raise ProducerException.new(String.new(errstr)) if @handle.null?
    end

    def produce(topic : String, payload : Bytes)
      err = LibRdKafka.producev(
        @handle,
        LibRdKafka::VTYPE::TOPIC, topic,
        LibRdKafka::VTYPE::VALUE, payload, payload.size,
        LibRdKafka::VTYPE::END
      )
      raise ProducerException.new(err) if err != LibRdKafka::OK
    end

    def produce(topic : String, key : Bytes, payload : Bytes)
      err = LibRdKafka.producev(
        @handle,
        LibRdKafka::VTYPE::TOPIC, topic,
        LibRdKafka::VTYPE::VALUE, payload, payload.size,
        LibRdKafka::VTYPE::KEY, key, key.size,
        LibRdKafka::VTYPE::END
      )
      raise ProducerException.new(err) if err != LibRdKafka::OK
    end

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
    end

    def produce(topic : String, msg : Message)
      rkt = LibRdKafka.topic_new(@handle, topic, nil)
      part = LibRdKafka::PARTITION_UNASSIGNED
      flags = LibRdKafka::MSG_FLAG_COPY
      err = LibRdKafka.produce(rkt, part, flags, msg.payload, msg.payload.size,
        msg.key, msg.key.size, nil)
      raise ProducerException.new(err) if err != LibRdKafka::OK
    ensure
      LibRdKafka.topic_destroy(rkt)
    end

    def produce_batch(topic : String, batch : Array({key: Array(UInt8), msg: Array(UInt8)}))
      rkt = LibRdKafka.topic_new(@handle, topic, nil)
      part = LibRdKafka::PARTITION_UNASSIGNED
      flags = LibRdKafka::MSG_FLAG_COPY
      batch.each do |t|
        err = LibRdKafka.produce(rkt, part, flags,
          t[:msg], t[:msg].size,
          t[:key], t[:key].size,
          nil)
        raise ProducerException.new(err) if err != LibRdKafka::OK
      end
      poll
    ensure
      LibRdKafka.topic_destroy(rkt)
    end

    def poll(timeout = 500)
      LibRdKafka.poll(@handle, timeout)
    end

    def flush(timeout = 1000)
      LibRdKafka.flush(@handle, timeout)
    end

    def finalize
      LibRdKafka.kafka_destroy(@handle)
    end
  end
end
