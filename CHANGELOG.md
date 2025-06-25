# Changelog

## [Unreleased]
### Changed
- Add `Consumer#stop` method to stop an `each` loop
- Add crystal versions 1.15.1 and 1.16.3 to test matrix

### Fixed
- Use ::sleep(Time::Span) instead of ::sleep(Number) to fix deprecations warnings with Crystal >= 1.14

## v0.6.0 - 2024-12-18
### Added
- Add `Kafka.version_info` and `Kafka.librdkafka_version` methods.

### Changed
- Update `Kafka::Consumer#poll` and `Kafka::Consumer#each` to automatically raise a `Kafka::ConsumerException` if the
  message is an error. Pass `raise_on_error: false` to maintain the previous behaviour.

## v0.5.0 - 2024-03-18
### Added
- Add `#topic` method to `Kafka::Message`. Thanks @oozzal!

## v0.4.2 - 2024-01-22
### Changed
- Upgrade Crystal version to v1.11.2

## v0.4.1 - 2024-01-04
### Added
- Fix to prevent exception when Delivery Report string is null pointer

## v0.4.0 - 2023-12-18
### Added
- Call `rd_kafka_poll` automatically in `Kafka::Producer`

## v0.3.3 - 2023-12-12
### Added
- Rename main src file

## v0.3.2 - 2023-12-12
### Added
- Save statistics option on `Kafka::Producer`

## v0.3.1 - 2023-11-14
### Fixed
- Remove topic + partition name from rebalance log

## v0.3.0 - 2023-11-14
### Added
- Integration & unit tests
- Documentation for all key methods and examples in the README

### Fixed
- Format all files using `crystal tool format`
- Add `Fiber.yield` at the start of each loop in `Kafka::Consumer#each` to allow other Fibers to run in between each iteration
- Fix `Invalid memory access` error and raise exception when unknown or invalid config passed to `Kafka::Consumer.new`
- Fix `Invalid memory access` error and raise exception when unknown or invalid config passed to `Kafka::Producer.new`
- Fix `Invalid memory access` error and raise exception when `LibRdKafka.kafka_new` fails to create consumer
- Fix `Invalid memory access` error and raise exception when `Kafka::Consumer#subscribe` fails to subscribe to topics
- Call `rd_kafka_destroy()` after closing consumer as advised in the librdkafka [documentation](https://github.com/confluentinc/librdkafka/blob/master/src/rdkafka.h#L4219-L4220)

### Changed
- Refactor setting rebalancing callback into separate class
- Refactor building of config for Producer/Consumer into separate class
- Improve logging around consumer partition assignment and producer delivery reports

## v0.2.0 - 2023-08-03
- Forked from https://github.com/CloudKarafka/kafka.cr

### Added
- Added new `Kafka::Producer#produce` method without key argument
