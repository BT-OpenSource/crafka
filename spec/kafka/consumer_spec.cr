require "../spec_helper"

describe Kafka::Consumer do
  describe "initialize" do
    it "raises an error when setting an unknown configuration key" do
      expect_raises(Exception, "Failed to load config - Unknown configuration name: incorrect") do
        Kafka::Consumer.new({"incorrect" => "config"})
      end
    end
  end
end
