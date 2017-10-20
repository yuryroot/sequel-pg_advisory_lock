$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sequel/extensions/pg_advisory_lock'

require 'minitest/autorun'
require 'yaml'

DB = Sequel.connect(ENV['PG_TEST_DB'] || 'postgres://localhost/postgres?user=postgres')
DB.extension(:pg_advisory_lock)