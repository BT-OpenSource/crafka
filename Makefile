setup:
	docker-compose -f spec/docker-compose.yml up -d

teardown:
	docker-compose -f spec/docker-compose.yml down