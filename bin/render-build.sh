#!/usr/bin/env bash
set -o errexit

bundle install
bin/rails assets:precompile
RAILS_ENV=production bin/rails db:prepare
