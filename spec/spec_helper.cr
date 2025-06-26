require "spec"
require "json"
require "../src/*"

def create_consumer
  Kafka::Consumer.new({"bootstrap.servers"     => "localhost:9094",
                       "group.id"              => "foo",
                       "broker.address.family" => "v4"})
end

def timeout(time : Time::Span, &blk)
  done = Channel(Nil).new

  spawn do
    blk.call
    done.send(nil)
  end

  select
  when done.receive
    return
  when timeout(time)
    raise "Timeout"
  end
end
