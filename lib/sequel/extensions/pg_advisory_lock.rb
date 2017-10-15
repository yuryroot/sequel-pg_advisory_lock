require 'sequel'
require 'zlib'

module Sequel
  module Postgres
    module PgAdvisoryLock

      LOCK_FUNCTIONS = %i[
        pg_advisory_lock
        pg_try_advisory_lock
        pg_advisory_xact_lock
        pg_try_advisory_xact_lock
      ].freeze

      DEFAULT_LOCK_FUNCTION = :pg_advisory_lock
      UNLOCK_FUNCTION = :pg_advisory_unlock

      def registered_advisory_locks
        @registered_advisory_locks ||= {}
      end

      def with_advisory_lock(name, id = nil, &block)
        options = registered_advisory_locks.fetch(name.to_sym)

        lock_key = options.fetch(:key)

        lock_function = options.fetch(:lock_function)
        function_params = [lock_key, id].compact

        synchronize do
          if get(Sequel.function(lock_function, *function_params))
            begin
              yield
            ensure
              get(Sequel.function(UNLOCK_FUNCTION, *function_params))
            end
          end
        end
      end

      def register_advisory_lock(name, lock_function = DEFAULT_LOCK_FUNCTION)
        name = name.to_sym

        if registered_advisory_locks.key?(name)
          raise Error, "Lock with name :#{name} is already registered"
        end

        key = advisory_lock_key_for(name)
        if registered_advisory_locks.values.any? { |opts| opts.fetch(:key) == key }
          raise Error, "Lock key #{key} is already taken"
        end

        function = lock_function.to_sym
        unless LOCK_FUNCTIONS.include?(function)
          raise Error, "Invalid lock function :#{function}"
        end

        registered_advisory_locks[name] = { key: key, lock_function: function }
      end

      def advisory_lock_key_for(lock_name)
        Zlib.crc32(lock_name.to_s) % 2 ** 31
      end

    end
  end

  Database.register_extension(:pg_advisory_lock, Postgres::PgAdvisoryLock)
end