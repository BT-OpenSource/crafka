module Kafka
  class Config
    def initialize(conf : Hash<String, String>)
      @conf_handle = LibKafkaC.conf_new()
      raise "Failed to allocate Kafka Config" unless @conf_handle
      conf.each do |k, v|
        res = LibKafkaC.conf_set(@conf_handle, k, v, out err, 128)
        raise "Kafka.Config: set('#{name}') failed: #{String.new err}" unless LibKafkaC::OK == res
      end
    end

    def finalize()
      begin
        LibC.free(@pErrStr)
        #LibKafkaC.conf_destroy(@conf_handle) if @conf_handle
      end
    end

    def to_unsafe
      return @conf_handle
    end

    def set_msg_callback(cb : Proc(LibKafkaC::KafkaHandle, Void*, Void*) )
      LibKafkaC.conf_set_dr_msg_cb @conf_handle, cb
    end
  end

end
