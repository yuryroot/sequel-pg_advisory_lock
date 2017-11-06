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
    before do
      subject.registered_advisory_locks.clear
    end

    def overlap?(array1, array2)
      (array1[0] - array2[1]) * (array2[0] - array1[1]) > 0
    end

    it 'check "pg_advisory_lock"' do
      subject.register_advisory_lock(:lock, :pg_advisory_lock)

      concurrency = 100
      threads = []

      fetched_locks = []
      fetched_locks_mutex = Mutex.new

      concurrency.times do
        threads << Thread.new do
          from, to = nil

          subject.with_advisory_lock(:lock) do
            from = Time.now.to_f
            sleep rand(0.001..0.01)
            to = Time.now.to_f
          end

          fetched_locks_mutex.synchronize do
            fetched_locks << [from, to] if from && to
          end
        end
      end

      threads.map(&:join)

      no_overlap_locks = fetched_locks.combination(2).none? do |lock1_info, lock2_info|
        overlap?(lock1_info, lock2_info)
      end

      assert no_overlap_locks
      assert_equal concurrency, fetched_locks.size
    end

    it 'check "pg_try_advisory_lock"' do
      subject.register_advisory_lock(:lock, :pg_try_advisory_lock)

      concurrency = 100
      threads = []

      fetched_locks_counter = 0
      fetched_locks_mutex = Mutex.new

      concurrency.times do
        threads << Thread.new do
          lock_fetched = false

          subject.with_advisory_lock(:lock) do
            lock_fetched = true
            sleep(2)
          end

          fetched_locks_mutex.synchronize do
            fetched_locks_counter += 1 if lock_fetched
          end
        end
      end

      threads.map(&:join)

      assert_equal 1, fetched_locks_counter
    end

    it 'check "pg_advisory_xact_lock"' do
      assert false
    end

    it 'check "pg_try_advisory_xact_lock"' do
      assert false
    end
  end
end
