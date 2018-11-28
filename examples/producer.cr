require "json"
require "../src/kafka"
require "../src/kafka/lib_rdkafka"

conf = { "bootstrap.servers" => "localhost:9092,localhost:9093"}
producer = Kafka::Producer.new(conf)
c = 0


struct User
  JSON.mapping(
    name: String,
    age: Int32,
    city: String
  )
  def initialize(@name : String, @age : Int32, @city : String)

  end
end

while true
  u = User.new("mange", 34, "sthlm")
  m = Kafka::Message.new(
    "user-#{c}".to_slice,
    u.to_json.to_slice
  )
  producer.producev("balance", m)
  producer.poll
  c += 1
end
producer.flush
