require "./lib_rdkafka.cr"

module Kafka
  class Producer
    # creates a new kafka handle using provided config.
    # Throws exception on error
    def initialize(config : Hash(String, String))
      conf = LibKafkaC.conf_new
      config.each do |k, v|
        res = LibKafkaC.conf_set(conf, k, v, out err, 128)
      end
      cb = ->(h : LibKafkaC::KafkaHandle, x : Void*, y : Void*) {
        puts "CB #{x}"
      }
      LibKafkaC.conf_set_dr_msg_cb(conf, cb)
      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_PRODUCER, conf, out errstr, 512)
      raise "Kafka: Unable to create new producer: #{errstr}" if @handle == 0_u64
      @polling = false
      @keep_running = true
    end

    def produce(topic : String, key : Bytes,  payload : Bytes)
      err = LibKafkaC.producev(
        @handle,
        LibKafkaC::VTYPE::TOPIC, topic,
        LibKafkaC::VTYPE::VALUE, payload, payload.size,
        LibKafkaC::VTYPE::KEY, key, key.size,
        LibKafkaC::VTYPE::END
      )
      raise KafkaProducerException.new(err) if err != LibKafkaC::OK
    end
    def produce(topic : String, key : Bytes,  payload : Bytes, timestamp : Int64)
      err = LibKafkaC.producev(
        @handle,
        LibKafkaC::VTYPE::TOPIC, topic,
        LibKafkaC::VTYPE::VALUE, payload, payload.size,
        LibKafkaC::VTYPE::KEY, key, key.size,
        LibKafkaC::VTYPE::TIMESTAMP, timestamp,
        LibKafkaC::VTYPE::END
      )
      raise KafkaProducerException.new(err) if err != LibKafkaC::OK
    end

    def produce0(topic : String, msg : Message)
      rkt = LibKafkaC.topic_new(@handle, topic, nil)
      part = LibKafkaC::PARTITION_UNASSIGNED
      flags = LibKafkaC::MSG_FLAG_COPY
      err = LibKafkaC.produce(rkt, part, flags, msg.payload, msg.payload.size,
                              msg.key, msg.key.size, nil)
      raise KafkaProducerException.new(err) if err != LibKafkaC::OK
    ensure
      LibKafkaC.topic_destroy(rkt)
    end

    def produce_batch(topic : String, batch : Array({key: Array(UInt8), msg: Array(UInt8)}))
      rkt = LibKafkaC.topic_new(@handle, topic, nil)
      part = LibKafkaC::PARTITION_UNASSIGNED
      flags = LibKafkaC::MSG_FLAG_COPY
      batch.each do |t|
        err = LibKafkaC.produce(rkt, part, flags,
                                t[:msg], t[:msg].size,
                                t[:key], t[:key].size,
                                nil)
        raise KafkaProducerException.new(err) if err != LibKafkaC::OK
      end
      poll
    ensure
      LibKafkaC.topic_destroy(rkt)
    end

    def poll(timeout = 500)
      LibKafkaC.poll(@handle, timeout)
    end

    def flush(timeout = 1000)
      @keep_running = false
      LibKafkaC.flush(@handle, timeout)
    end

    def finalize()
      LibKafkaC.kafka_destroy(@handle)
    end

  end
end
