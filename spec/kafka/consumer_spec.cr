require "../spec_helper"

describe Kafka::Consumer do
  describe "initialize" do
    it "raises an error when setting an unknown configuration key" do
      expect_raises(Exception, "Failed to load config - Unknown configuration name: incorrect") do
        Kafka::Consumer.new({"incorrect" => "config"})
      end
    end

    it "raises an error with multiple errors in it" do
      expect_raises(Exception, "Failed to load config - Unknown configuration name: incorrect. Unknown configuration name: another") do
        Kafka::Consumer.new({"incorrect" => "config", "another" => "bad_one"})
      end
    end

    it "raises an error when setting an invalid configuration value" do
      expect_raises(Exception, "Failed to load config - Invalid configuration value or property or value not supported in this build: broker.address.family") do
        Kafka::Consumer.new({"broker.address.family" => "foo"})
      end
    end
  end
end
