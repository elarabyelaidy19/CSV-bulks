FROM ruby:3.3.5-bullseye

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client \
  libvips

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .