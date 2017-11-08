require_relative './test_helper'

describe Sequel::Postgres::PgAdvisoryLock do
  subject { DB }

  describe '#with_advisory_lock' do
    before do
      subject.registered_advisory_locks.clear
    end

    def overlap?(array1, array2)
      (array1[0] - array2[1]) * (array2[0] - array1[1]) > 0
    end

    def check_concurrent_lock_access(registered_lock_name, concurrency, around_transaction = false)
      threads = []
      fetched_locks = []
      fetched_locks_mutex = Mutex.new

      advisory_lock_proc = proc do |lock_name|
        from, to = nil

        subject.with_advisory_lock(lock_name) do
          from = Time.now.to_f
          sleep rand(0.001..0.01)
          to = Time.now.to_f
        end

        [from, to]
      end

      concurrency.times do
        threads << Thread.new do
          from, to =
            if around_transaction
              subject.transaction do
                advisory_lock_proc.call(registered_lock_name)
              end
            else
              advisory_lock_proc.call(registered_lock_name)
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

    def check_concurrent_try_lock_access(registered_lock_name, concurrency, around_transaction = false)
      threads = []
      fetched_locks_counter = 0
      fetched_locks_mutex = Mutex.new

      advisory_lock_proc = proc do |lock_name|
        lock_fetched = false

        subject.with_advisory_lock(lock_name) do
          lock_fetched = true
          sleep(2)
        end

        lock_fetched
      end

      concurrency.times do
        threads << Thread.new do
          lock_fetched =
            if around_transaction
              subject.transaction do
                advisory_lock_proc.call(registered_lock_name)
              end
            else
              advisory_lock_proc.call(registered_lock_name)
            end

          fetched_locks_mutex.synchronize do
            fetched_locks_counter += 1 if lock_fetched
          end
        end
      end

      threads.map(&:join)

      assert_equal 1, fetched_locks_counter
    end

    it 'check "pg_advisory_lock"' do
      subject.register_advisory_lock(:lock, :pg_advisory_lock)
      check_concurrent_lock_access(:lock, 100)
    end

    it 'check "pg_try_advisory_lock"' do
      subject.register_advisory_lock(:lock, :pg_try_advisory_lock)
      check_concurrent_try_lock_access(:lock, 100)
    end

    it 'check "pg_advisory_xact_lock"' do
      subject.register_advisory_lock(:lock, :pg_advisory_xact_lock)
      check_concurrent_lock_access(:lock, 100, true)
    end

    it 'check "pg_try_advisory_xact_lock"' do
      subject.register_advisory_lock(:lock, :pg_try_advisory_xact_lock)
      check_concurrent_try_lock_access(:lock, 100, true)
    end

    it 'requires transaction opened before using transaction level lock' do
      %i[
        pg_advisory_xact_lock
        pg_try_advisory_xact_lock
      ].each do |lock_function|
        subject.register_advisory_lock(lock_function, lock_function)

        exception = assert_raises do
          subject.with_advisory_lock(lock_function) { }
        end

        assert_match /Transaction must be manually opened before using transaction level lock/, exception.message
      end
    end
  end
end
