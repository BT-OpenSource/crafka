require "../src/kafka"

conf = {#"debug" => "broker",
  "bootstrap.servers" => "localhost:9092",
  "group.id" => "mange3"}

consumer = Kafka::Consumer.new(conf)
consumer.subscribe("balance", "asd", "asd2")
consumer.each do |m|
  puts "key=#{String.new(m.key)}, payload=#{String.new(m.payload)}"
end
consumer.close
