# Changelog

## [Unreleased]
### Added
- Integration & unit tests
- Raise exception when unknown or invalid config passed to `Kafka::Consumer.new`

### Fixed
- Format all files using `crystal tool format`
- Add `Fiber.yield` at the start of each loop in `Kafka::Consumer#each` to allow other Fibers to run when using `#each`

### Changed
- Refactor setting rebalancing callback into separate class

###


## [0.2.0] - 2023-08-03
- Forked from https://github.com/CloudKarafka/kafka.cr

### Added
- Added new `Kafka::Producer#produce` method with key argument