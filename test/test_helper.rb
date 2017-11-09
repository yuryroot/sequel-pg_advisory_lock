$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sequel/extensions/pg_advisory_lock'

require 'minitest/autorun'
require 'yaml'
require 'set'

database = ENV['TEST_DB_NAME'] || 'postgres'
user     = ENV['TEST_DB_USER'] || 'postgres'

connection_string_prefix =
  if RUBY_PLATFORM =~ /java/
    'jdbc:postgresql://'
  else
    'postgres://'
  end

connection_string = "#{connection_string_prefix}localhost/#{database}?user=#{user}"

DB = Sequel.connect(connection_string, pool_timeout: 10)

DB.extension(:pg_advisory_lock)