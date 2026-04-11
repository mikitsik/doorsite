#!/usr/bin/env bash
set -o errexit

export RAILS_ENV=production

bundle install
bin/rails assets:precompile
bin/rails db:prepare

