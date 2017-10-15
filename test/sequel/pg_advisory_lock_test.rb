require 'test_helper'

describe Sequel::Postgres::PgAdvisoryLock do

  describe '#register_advisory_lock' do

    it 'should register locks for all known PostgreSQL functions' do
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

    it 'Sequel.synchronize must be used inside block' do
      assert false
    end

    it 'should call PostgreSQL function of type that specified in register method' do
      assert false
    end

    it 'should call PostgreSQL function with one argument if "id" is not specified' do
      assert false
    end

    it 'should call PostgreSQL function with two arguments if "id" is specified' do
      assert false
    end

    it 'should release lock after block call' do
      assert false
    end

    it '"try" locks should not wait locks releasing' do
      assert false
    end

    describe 'locks' do

      it 'check "pg_advisory_lock"' do
        assert false
      end

      it 'check "pg_try_advisory_lock"' do
        assert false
      end

      it 'check "pg_advisory_xact_lock"' do
        assert false
      end

      it 'check "pg_try_advisory_xact_lock"' do
        assert false
      end
    end
  end
end
