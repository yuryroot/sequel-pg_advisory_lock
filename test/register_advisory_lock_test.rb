require_relative './test_helper'

describe Sequel::Postgres::PgAdvisoryLock do
  subject { DB }

  describe '#register_advisory_lock' do
    let(:supported_lock_functions) do
      [
        :pg_advisory_lock,
        :pg_try_advisory_lock,
        :pg_advisory_xact_lock,
        :pg_try_advisory_xact_lock
      ]
    end

    let(:default_lock_function) { :pg_advisory_lock }

    before do
      subject.registered_advisory_locks.clear
    end

    it 'base check' do
      lock_name = :test_lock

      assert_nil subject.registered_advisory_locks[lock_name]
      subject.register_advisory_lock(lock_name)
      assert_equal default_lock_function, subject.registered_advisory_locks[lock_name].fetch(:lock_function)
    end

    it 'should register locks for all supported PostgreSQL functions' do
      supported_lock_functions.each do |lock_function|
        lock_name = "#{lock_function}_test".to_sym

        assert_nil subject.registered_advisory_locks[lock_name]
        subject.register_advisory_lock(lock_name, lock_function)
        assert_equal lock_function, subject.registered_advisory_locks[lock_name].fetch(:lock_function)
      end
    end

    it 'should prevent specifying not supported PostgreSQL function as lock type' do
      lock_name = :not_supported_lock_function_test
      lock_function = :not_supported_lock_function

      exception = assert_raises do
        subject.register_advisory_lock(lock_name, lock_function)
      end
      assert_match /Invalid lock function/, exception.message
    end

    it 'should prevent registering multiple locks with same name' do
      lock_name = :multiple_locks_with_same_name_test
      subject.register_advisory_lock(lock_name, supported_lock_functions[0])

      exception = assert_raises do
        subject.register_advisory_lock(lock_name, supported_lock_functions[1])
      end
      assert_match /Lock with name .+ is already registered/, exception.message
    end

    it 'registered locks must have different lock keys' do
      quantity = 100
      quantity.times do |index|
        lock_name = "test_lock_#{index}".to_sym
        subject.register_advisory_lock(lock_name)
      end

      assert_equal quantity, subject.registered_advisory_locks.size
      all_keys = subject.registered_advisory_locks.values.map { |v| v.fetch(:key) }
      assert_equal all_keys.size, all_keys.uniq.size
    end

    it 'mapping between lock name and lock key must be constant' do
      assert_empty subject.registered_advisory_locks

      lock_names_keys_mapping = YAML.load_file(File.join(File.dirname(__FILE__), 'lock_names_keys.yml'))

      lock_names_keys_mapping.each do |lock_name, valid_lock_key|
        lock_name = lock_name.to_sym
        subject.register_advisory_lock(lock_name)
        assert_equal valid_lock_key, subject.registered_advisory_locks[lock_name].fetch(:key)
      end
    end
  end
end
