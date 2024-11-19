#!/usr/bin/env bash

set -xeuo pipefail

bundle

bundle exec sidekiq -C config/sidekiq.yml