require "../spec_helper"

describe "Consumer error handling" do
  describe "#poll" do
    it "raises errors by default" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "127.0.0.1:9094", "group.id" => "foo_group", "broker.address.family" => "v4"})
      consumer.subscribe("non-existent-topic")

      expect_raises(Kafka::ConsumerException, "librdkafka error - Broker: Unknown topic or partition") do
        consumer.poll(timeout_ms: 10_000)
      end
    ensure
      consumer.try(&.close)
    end

    it "doesn't raise errors when raise_on_error is false" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "127.0.0.1:9094", "group.id" => "foo_group", "broker.address.family" => "v4"})
      consumer.subscribe("non-existent-topic")

      message = consumer.poll(timeout_ms: 10_000, raise_on_error: false)
      message.not_nil!.err.not_nil!.message.should eq "Broker: Unknown topic or partition"
    ensure
      consumer.try(&.close)
    end
  end

  describe "#each" do
    it "raises errors by default" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "127.0.0.1:9094", "group.id" => "foo_group", "broker.address.family" => "v4"})
      consumer.subscribe("non-existent-topic")

      expect_raises(Kafka::ConsumerException, "librdkafka error - Broker: Unknown topic or partition") do
        consumer.each(timeout: 1000) do |_message|
          break
        end
      end
    ensure
      consumer.try(&.close)
    end

    it "doesn't raise errors when raise_on_error is false" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "127.0.0.1:9094", "group.id" => "foo_group", "broker.address.family" => "v4"})
      consumer.subscribe("non-existent-topic")

      consumer.each(timeout: 1000, raise_on_error: false) do |message|
        message.err.not_nil!.message.should eq "Broker: Unknown topic or partition"
        break
      end
    ensure
      consumer.try(&.close)
    end
  end
end
