require "./lib_rdkafka.cr"

module Kafka
  class Client
    getter handle
    def initialize(config : Hash(String, String), client_type : Int32)
    end

  end
end
