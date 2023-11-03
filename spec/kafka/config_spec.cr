require "../spec_helper"

describe Kafka::Config do
  describe ".build" do
    it "raises an error when setting an unknown configuration key" do
      expect_raises(Exception, "Failed to load config - Unknown configuration name: incorrect") do
        Kafka::Config.build({"incorrect" => "config"})
      end
    end

    it "raises an error with multiple errors in it" do
      expect_raises(Exception, "Failed to load config - Unknown configuration name: incorrect. Unknown configuration name: another") do
        Kafka::Config.build({"incorrect" => "config", "another" => "bad_one"})
      end
    end

    it "raises an error when setting an invalid configuration value" do
      expect_raises(Exception, "Failed to load config - Invalid configuration value or property or value not supported in this build: broker.address.family") do
        Kafka::Config.build({"broker.address.family" => "foo"})
      end
    end
  end
end
