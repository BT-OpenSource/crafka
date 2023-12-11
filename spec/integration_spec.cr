require "./spec_helper"
require "file_utils"

describe "Producing & Consuming" do
  it "can produce messages to and consume messages from Kafka" do
    producer = Kafka::Producer.new({"bootstrap.servers" => "127.0.0.1:9094", "broker.address.family" => "v4"})
    consumer = Kafka::Consumer.new({"bootstrap.servers" => "127.0.0.1:9094", "group.id" => "foo_group", "broker.address.family" => "v4"})
    consumer.subscribe("foo")

    message = nil
    iterations = 0
    loop do
      iterations += 1
      print "."
      producer.produce(topic: "foo", payload: {"foo" => "bar"}.to_json.to_slice)
      producer.flush

      message = consumer.poll(1000)
      break if !message.nil? || iterations >= 10
    end

    raise "message is nil" if message.nil?

    String.new(message.payload).should eq({"foo" => "bar"}.to_json)
  ensure
    consumer.try(&.close)
    producer.try(&.finalize)
  end
end

describe "Statistics" do
  after_each do
    FileUtils.rm("#{__DIR__}/librdkafka_stats.json")
  end

  it "allows you to capture the statistic reports from librdkafka" do
    producer = Kafka::Producer.new(
      {"bootstrap.servers" => "127.0.0.1:9094", "broker.address.family" => "v4", "statistics.interval.ms" => "10"},
      stats_path: __DIR__
    )
    3.times do
      producer.produce(topic: "stats", payload: "foo".to_slice)
      producer.poll
      producer.flush
    end

    File.exists?("#{__DIR__}/librdkafka_stats.json").should be_true
  ensure
    producer.try(&.finalize)
  end
end
