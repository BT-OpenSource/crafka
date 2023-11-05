require "../spec_helper"

describe Kafka::Consumer do
  describe "initializer" do
    it "raises an error when the consumer creation fails" do
      expect_raises(Exception, "Unable to create consumer - Invalid sasl.kerberos.kinit.cmd value: Property not available: \"sasl.kerberos.keytab\"") do
        Kafka::Consumer.new({"security.protocol" => "SASL_SSL", "sasl.mechanism" => "GSSAPI"})
      end
    end
  end

  describe "#subscribe" do
    it "raises an exception when given no topics" do
      expect_raises(Kafka::ConsumerException, "librdkafka error - Local: Invalid argument or configuration") do
        consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9094", "group.id" => "foo", "broker.address.family" => "v4"})
        consumer.subscribe("")
      end
    end
  end
end
