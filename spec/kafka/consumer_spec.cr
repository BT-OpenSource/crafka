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
  end
end
