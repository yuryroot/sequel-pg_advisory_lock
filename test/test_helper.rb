$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sequel/extensions/pg_advisory_lock'

require 'minitest/autorun'
