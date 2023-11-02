require "./spec_helper"

describe Kafka::Consumer do
  it "consumes kafka messages and stores new alarms" do
    producer = Kafka::Producer.new({
      "bootstrap.servers"     => "127.0.0.1:9094",
      "broker.address.family" => "v4",
    })
    consumer = Kafka::Consumer.new({"bootstrap.servers" => "127.0.0.1:9094", "group.id" => "foo_group", "broker.address.family" => "v4"})
    consumer.subscribe("foo")

    message = nil
    loop do
      print "."
      producer.produce(topic: "foo", payload: {"foo" => "bar"}.to_json.to_slice)
      sleep(0.5)

      message = consumer.poll(1000)

      break if !message.nil?
    end

    raise "message is nil" if message.nil?

    String.new(message.payload).should eq "{\"foo\":\"bar\"}"

    consumer.close
  end
end
