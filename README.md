# crafka

[![Build Status](https://github.com/BT-OpenSource/crafka/actions/workflows/ci.yml/badge.svg)](https://github.com/BT-OpenSource/crafka/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/BT-OpenSource/crafka)](https://github.com/BT-OpenSource/crafka/releases)
[![License](https://img.shields.io/github/license/BT-OpenSource/crafka)](https://github.com/BT-OpenSource/crafka/blob/main/LICENSE)

Detailed documentation: https://crystaldoc.info/github/BT-OpenSource/crafka/main/index.html

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crafka:
    github: bt-opensource/crafka
```

## Usage

```crystal
require "crafka"
```

### Producing
```crystal
producer = Kafka::Producer.new({"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4"})
producer.produce(topic: "topic_name", payload: "my message".to_slice)

# Optionally
producer.poll # Serves queued callbacks
producer.flush # Wait for outstanding produce requests to complete
```
All available args to `#produce`: `topic`, `payload`, `key`, `timestamp`.

#### Auto Polling
librdkafka recommends that [`rd_kafka_poll`](https://github.com/confluentinc/librdkafka/blob/master/src/rdkafka.h#L3200-L3228) is called at regular intervals to serve queued callbacks. This functionality is built in to Crafka.

By default after each `#produce`, a `Kafka::Producer` will call poll if it hasn't polled in the last 5 seconds.

You can configure this with the `poll_interval` argument:

```crystal
producer = Kafka::Producer.new(
  {"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4"},
  poll_interval: 30
)
```

To disable auto polling, set `poll_interval` to 0.

#### Debug Statistics

To enable capturing of the statistics described [here](https://github.com/confluentinc/librdkafka/blob/master/STATISTICS.md) you can pass a `stats_path` argument to `Kafka::Producer.new` containing the location of a file to be written to.

Also ensure that you set the `statistics.interval.ms` in your producer config.

```crystal
producer = Kafka::Producer.new(
  {"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4", "statistics.interval.ms" => "5000"},
  stats_path: "/some/directory/librdkafka_stats.json"
)
```

---

### Consuming
```crystal
consumer = Kafka::Consumer.new({"bootstrap.servers" => "localhost:9092", "broker.address.family" => "v4", "group.id" => "consumer_group_name"})
consumer.subscribe("topic_name")
consumer.each do |message|
  # message is an instance of Kafka::Message
  puts "#{String.new(message.topic)} -> #{String.new(message.payload)}"
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

### Releasing
1. Update shard.yml and `src/crafka.cr` with new version number
2. Update CHANGELOG.md with changes
3. Commit and tag commit

## Credits
Originally forked from: https://github.com/CloudKarafka/kafka.cr
