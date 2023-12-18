require "../spec_helper"
require "file_utils"

describe "Statistics" do
  it "allows you to capture the statistic reports from librdkafka" do
    stats_file = "#{__DIR__}/librdkafka_stats.json"
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
    File.read(stats_file).should contain "rdkafka#producer-"
  ensure
    producer.try(&.finalize)
    FileUtils.rm(stats_file.as(String)) if File.exists?(stats_file.as(String))
  end
end
