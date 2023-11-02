# kafka.cr

Forked from: https://github.com/CloudKarafka/kafka.cr

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kafka:
    git: https://gitlab.agile.nat.bt.com/APP15256/kafka.cr.git
```

## Usage

```crystal
require "kafka"
```

## Development

### Testing
```
docker-compose -f spec/docker-compose.yml up -d
crystal spec
```
