require_relative '../test_helper'

describe Sequel::Postgres::PgAdvisoryLock do
  subject { DB }

  describe '#register_advisory_lock' do
    let(:supported_lock_functions) do
      %i[
        pg_advisory_lock
        pg_try_advisory_lock
        pg_advisory_xact_lock
        pg_try_advisory_xact_lock
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

  describe '#with_advisory_lock' do
    it 'check "pg_advisory_lock"' do
      subject.register_advisory_lock(:lock, :pg_advisory_lock)

      concurrency = 100
      threads = []
      state_mutex = Mutex.new

      started_threads = []
      fetched_threads = []
      released_threads = []
      active_locks = Set.new

      Thread.abort_on_exception = true

      concurrency.times do |index|
        threads << Thread.new(index) do |thread_number|
          state_mutex.synchronize { started_threads << thread_number }

          subject.with_advisory_lock(:lock) do
            state_mutex.synchronize do
              fetched_threads << thread_number
              active_locks << thread_number
            end

            sleep rand(0.001..0.01)
          end

          state_mutex.synchronize do
            released_threads << thread_number
            active_locks.delete(thread_number)

            assert_operator active_locks.count, :<=, 1
            assert_operator started_threads.count, :>=, fetched_threads.count
            assert_operator released_threads.count, :<=, fetched_threads.count
          end
        end
      end

      threads.map(&:join)

      assert_equal concurrency, started_threads.count
      assert_equal concurrency, fetched_threads.count
      assert_equal concurrency, released_threads.count
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
