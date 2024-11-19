#!/usr/bin/env bash

set -xeuo pipefail

LOCKFILE=.db-migrated

cleanup() {
  rm -f $LOCKFILE
}

trap cleanup EXIT

while [[ -f $LOCKFILE ]]; do
  echo "Waiting for migration to finish..."
  sleep 10
done

touch $LOCKFILE

if [[ -f ./tmp/pids/server.pid ]]; then
  rm ./tmp/pids/server.pid
fi

bundle

if ! [[ -f .db-created ]]; then
  bin/rails db:drop db:create
  touch .db-created
fi

bin/rails db:create
bin/rails db:migrate

if ! [[ -f .db-seeded ]]; then
  bin/rails db:seed
  touch .db-seeded
fi

nohup bundle exec rake assets:precompile &

cleanup

bin/rails server --port 3000 --binding 0.0.0.0