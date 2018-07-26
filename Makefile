OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

all: deps lint test checks

lint:
	@echo "$(OK_COLOR)==> Linting... $(NO_COLOR)"
	@go vet ./...

test:
	@go test -v -cover ./...

deps:
	@echo "$(OK_COLOR)==> Installing dependencies $(NO_COLOR)"
	@go get -u gopkg.in/mgo.v2
	@go get -u github.com/go-sql-driver/mysql
	@go get -u github.com/lib/pq
	@go get -u github.com/streadway/amqp
	@go get -u github.com/garyburd/redigo/redis

checks:
	@docker-compose up -d
	@sleep 3
	@echo "$(OK_COLOR)==> Running checks tests against container deps $(NO_COLOR)" && \
		HEALTH_GO_PG_DSN="postgres://test:test@`docker-compose port postgres 5432`/test?sslmode=disable" \
		HEALTH_GO_MQ_DSN="http://guest:guest@`docker-compose port rabbit 15672`/" \
		HEALTH_GO_RD_DSN="redis://`docker-compose port redis 6379`/" \
		HEALTH_GO_MG_DSN="`docker-compose port mongo 27017`/" \
		HEALTH_GO_MS_DSN="test:test@tcp(`docker-compose port mysql 3306`)/test?charset=utf8" \
		HEALTH_GO_HTTP_URL="http://`docker-compose port http 80`/status" \
		go test -v -cover ./...

.PHONY: all deps test lint checks
