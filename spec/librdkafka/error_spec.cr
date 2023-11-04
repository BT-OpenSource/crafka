require "../spec_helper"

describe LibRdKafka::Error do
  describe "#message" do
    it "converts the error code to it's description" do
      LibRdKafka::Error.new(56).message.should eq "Broker: Disk error when trying to access log file on disk"
    end
  end
end
