require 'test_helper'

describe Sequel::Postgres::PgAdvisoryLock do

  describe '#register_advisory_lock' do

    it 'should register lock for all known PostgreSQL functions' do
      assert false
    end

    it 'should prevent specifying invalid PostgreSQL function as lock type' do
      assert false
    end

    it 'should prevent registering multiple locks with same name' do
      assert false
    end

    it 'registered locks must have different lock keys' do
      assert false
    end

    it 'mapping between lock name and lock key must be constant' do
      assert false
    end
  end

  describe '#with_advisory_lock' do

  end

end
