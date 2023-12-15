require "../spec_helper"
require "file_utils"

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
