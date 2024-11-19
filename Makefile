include .env

build:
	docker compose build

dev: up bash

up:
	docker compose up -d

bash:
	docker compose exec app bash
console:
	docker compose exec app rails console
tests: 
	docker compose exec app bundle exec rspec
seed:
	docker compose exec app bundle exec rails db:seed

restart:
	docker compose restart

stop:
	docker compose stop

down:
	docker compose down

psql:
	docker compose exec db psql -U ${POSTGRES_USER} ${POSTGRES_DB_NAME}