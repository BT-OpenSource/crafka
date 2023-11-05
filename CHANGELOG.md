# Changelog

## [Unreleased]
### Added
- Integration & unit tests

### Fixed
- Format all files using `crystal tool format`
- Add `Fiber.yield` at the start of each loop in `Kafka::Consumer#each` to allow other Fibers to run when using `#each`
- Fix `Invalid memory access` error and raise exception when unknown or invalid config passed to `Kafka::Consumer.new`
- Fix `Invalid memory access` error and raise exception when `LibRdKafka.kafka_new` fails to create consumer
- Fix `Invalid memory access` error and raise exception when `Kafka::Consumer#subscribe` fails to subscribe to topics
- Call `rd_kafka_destroy()` after closing consumer as advised in the [documentation](https://github.com/confluentinc/librdkafka/blob/master/src/rdkafka.h#L4219-L4220)

### Changed
- Refactor setting rebalancing callback into separate class

## [0.2.0] - 2023-08-03
- Forked from https://github.com/CloudKarafka/kafka.cr

### Added
- Added new `Kafka::Producer#produce` method with key argument