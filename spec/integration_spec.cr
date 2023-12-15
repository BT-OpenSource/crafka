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
  stats_file = "#{__DIR__}/librdkafka_stats.json"

  after_each do
    FileUtils.rm(stats_file) if File.exists?(stats_file)
  end

  it "allows you to capture the statistic reports from librdkafka" do
    producer = Kafka::Producer.new(
      {"bootstrap.servers" => "127.0.0.1:9094", "broker.address.family" => "v4", "statistics.interval.ms" => "10"},
      stats_path: stats_file
    )

    3.times do
      producer.produce(topic: "stats", payload: "foo".to_slice)
      producer.poll
      producer.flush
    end

    File.exists?(stats_file).should be_true
    File.read(stats_file).should contain "{ \"name\": \"rdkafka#producer-1\""
  ensure
    producer.try(&.finalize)
  end
end

describe "Auto polling" do
  stats_file = "#{__DIR__}/librdkafka_autopolling_stats.json"

  after_each do
    FileUtils.rm(stats_file) if File.exists?(stats_file)
  end

  it "calls #poll following #produce after the given polling interval" do
    producer = Kafka::Producer.new(
      {"bootstrap.servers" => "127.0.0.1:9094", "broker.address.family" => "v4", "statistics.interval.ms" => "10"},
      stats_path: stats_file,
      poll_interval: 1
    )

    sleep(2)
    producer.produce(topic: "autopolling", payload: "foo".to_slice)

    # rd_kafka_poll triggers all callbacks including stats capture, so we use this as confirmation poll has been called
    File.exists?(stats_file).should be_true
    producer.flush
  end

  it "doesn't call #poll following #produce when the given interval hasn't passed since the last poll" do
    producer = Kafka::Producer.new(
      {"bootstrap.servers" => "127.0.0.1:9094", "broker.address.family" => "v4", "statistics.interval.ms" => "10"},
      stats_path: stats_file,
      poll_interval: 1
    )

    sleep(2)
    producer.produce(topic: "autopolling", payload: "foo".to_slice)

    FileUtils.rm(stats_file)
    producer.produce(topic: "autopolling", payload: "foo".to_slice)

    File.exists?(stats_file).should be_false
    producer.flush
  end
end
