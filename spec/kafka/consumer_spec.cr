require "../spec_helper"

describe Kafka::Consumer do
  describe "initializer" do
    it "raises an error when the consumer creation fails" do
      expect_raises(Kafka::ConsumerException, "librdkafka error - Invalid sasl.kerberos.kinit.cmd value: Property not available: \"sasl.kerberos.keytab\"") do
        Kafka::Consumer.new({"security.protocol" => "SASL_SSL", "sasl.mechanism" => "GSSAPI"})
      end
    end
  end

  describe "#subscribe" do
    it "raises an exception when given no topics" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})

      expect_raises(Kafka::ConsumerException, "librdkafka error - Local: Invalid argument or configuration") do
        consumer.subscribe("")
      end
    end

    it "raises an exception when given duplicate topics" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})

      expect_raises(Kafka::ConsumerException, "librdkafka error - Local: Invalid argument or configuration") do
        consumer.subscribe("foo", "foo")
      end
    end

    it "raises an exception when called after the consumer is closed" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
      consumer.close
      expect_raises(Kafka::ConsumerException, "librdkafka error - Consumer closed") do
        consumer.subscribe("foo")
      end
    end
  end

  describe "#poll" do
    it "raises an exception when called after the consumer is closed" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
      consumer.close
      expect_raises(Kafka::ConsumerException, "librdkafka error - Consumer closed") do
        consumer.poll(250)
      end
    end
  end

  describe "#each" do
    it "returns when stopped" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})

      spawn do
        until consumer.running?
          sleep(30.milliseconds)
        end
        consumer.stop
      end

      timeout(5.seconds) do
        consumer.each(timeout: 10) { }
      end
    end

    it "raises an exception when called after the consumer is closed" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
      consumer.close
      expect_raises(Kafka::ConsumerException, "librdkafka error - Consumer closed") do
        consumer.each { }
      end
    end
  end

  describe "#open?" do
    it "returns true after creation" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
      consumer.open?.should be_true
    end

    it "returns false after closing" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
      consumer.close
      consumer.open?.should be_false
    end
  end

  describe "#close" do
    it "does not raise an exception when called multiple times" do
      consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
      2.times { consumer.close }
    end
  end
end
