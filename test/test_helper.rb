$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sequel/extensions/pg_advisory_lock'

require 'minitest/autorun'
require 'yaml'
require 'set'

DB = Sequel.connect(ENV['PG_TEST_DB'] || 'postgres://localhost/postgres?user=postgres', pool_timeout: 10)
DB.extension(:pg_advisory_lock)