.PHONY: all setup teardown format test test_unit test_integration ok clean

all: format test ok

setup:
	@echo "🚀 \033[0;34;4mStarting docker containers\033[0m"
	docker-compose -f spec/docker-compose.yml up -d
	@echo

teardown:
	@echo "🚀 \033[0;34;4mStopping docker containers\033[0m"
	docker-compose -f spec/docker-compose.yml down
	@echo

format:
	@echo "🚀 \033[0;34;4mChecking formatting\033[0m"
	crystal tool format --check
	@echo

test: test_unit test_integration

test_unit:
	@echo "🚀 \033[0;34;4mRunning unit tests\033[0m"
	crystal spec -v --color spec/{kafka,rdkafka}
	@echo

test_integration: setup
	@echo "🚀 \033[0;34;4mRunning integration tests\033[0m"
	crystal spec -v --color spec/integration
	@echo

ok:
	@echo "\n\033[1m\033[31m*\033[33m*\033[32m*\033[34m*\033[35m*\033[32m ALL TESTS PASSED\033[35m*\033[34m*\033[32m*\033[33m*\033[31m*\033[0m\n"

clean: teardown
