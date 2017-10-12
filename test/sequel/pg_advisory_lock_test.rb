require 'test_helper'

class Sequel::PgAdvisoryLockTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sequel::PgAdvisoryLock::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
