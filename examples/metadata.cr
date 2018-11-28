require "../src/kafka/lib_rdkafka"

conf_handle = LibKafkaC.conf_new
LibKafkaC.conf_set(conf_handle, "debug", "all", out errStr, 512)
handle = LibKafkaC.kafka_new(
  LibKafkaC::TYPE_PRODUCER,
  conf_handle, out pErrStr, 512)
if handle.not_nil!.address == 0_u64
  puts "Unable to create client"
  exit 1
end

brokers = if ARGV.empty?
            "localhost:9092"
          else
            ARGV.join(",")
          end

err = LibKafkaC.brokers_add(handle, brokers)
if err != LibKafkaC::OK
  puts "brokers_add: #{String.new(LibKafkaC.err2str(err))}"
  exit 1
end

v = LibKafkaC::Metadata.new
m = pointerof(v)
while true
  err = LibKafkaC.metadata(handle, 1, nil,  pointerof(m), 5000)
  if err != LibKafkaC::OK
    puts "metadata: #{String.new(LibKafkaC.err2str(err))}"
  else
    puts m.value
  end
  LibKafkaC.metadata_destroy(m)
end
