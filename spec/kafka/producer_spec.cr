require "../spec_helper"

describe Kafka::Producer do
  describe "initializer" do
    it "raises an error when the consumer creation fails" do
      expect_raises(Kafka::ProducerException, "librdkafka error - Invalid sasl.kerberos.kinit.cmd value: Property not available: \"sasl.kerberos.keytab\"") do
        Kafka::Producer.new({"security.protocol" => "SASL_SSL", "sasl.mechanism" => "GSSAPI"})
      end
    end
  end
end
