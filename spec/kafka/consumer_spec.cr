require "../spec_helper"

describe Kafka::Consumer do
  it "raises an error when the consumer creation fails" do
    expect_raises(Exception, "Unable to create consumer - Invalid sasl.kerberos.kinit.cmd value: Property not available: \"sasl.kerberos.keytab\"") do
      Kafka::Consumer.new({"security.protocol" => "SASL_SSL", "sasl.mechanism" => "GSSAPI"})
    end
  end
end
