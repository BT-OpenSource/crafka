# crafka



## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crafka:
    git: https://gitlab.agile.nat.bt.com/APP15256/crafka.git
```

## Usage

```crystal
require "crafka"
```

### Producing
```crystal
producer = Kafka::Producer.new({"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4"})
producer.produce(topic: "topic_name", payload: "my message".to_slice)
producer.poll # Serves queued callbacks
producer.flush # Wait for outstanding produce requests to complete
```
All available args to `#produce`: `topic`, `payload`, `key`, `timestamp`.

#### Debug Statistics

To enable capturing of the statistics described [here](https://github.com/confluentinc/librdkafka/blob/master/STATISTICS.md) you can pass a `stats_path` argument to `Kafka::Producer.new` containing the location of a file to be written to.

Also ensure that you set the `statistics.interval.ms` in your producer config.

```crystal
producer = Kafka::Producer.new(
  {"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4", "statistics.interval.ms" => "5000"},
  stats_path: "/some/directory/librdkafka_stats.json"
)
```

### Consuming
```crystal
consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4", "group.id" => "consumer_group_name"})
consumer.subscribe("topic_name")
consumer.each do |message|
  # message is an instance of Kafka::Message
  puts message.payload
end
consumer.close
```

#### Subscribing to multiple topics
```crystal
consumer.subscribe("topic_name", "another_topic", "more_and_more")

consumer.subscribe("^starts_with") # subscribe to multiple with a regex
```

## Development

### Running Tests
```
make setup
crystal spec
```

## Credits
Originally forked from: https://github.com/CloudKarafka/kafka.cr
