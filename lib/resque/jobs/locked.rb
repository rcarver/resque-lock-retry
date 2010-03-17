module Resque
  module Jobs
    class Locked

      def self.locked?(*args)
        Resque.redis.exists "locked:#{lock(*args)}"
      end

      def self.perform(*args)
        with_lock(*args) { perform_without_lock(*args) }
      end

      def self.lock(*args)
        "#{name}-#{args.to_s}"
      end

      def self.lock_time
        60
      end

      # Locking algorithm: http://code.google.com/p/redis/wiki/SetnxCommand
      def self.with_lock(*args)
        now = Time.now.to_i
        lock_key = "locked:#{lock(*args)}"
        lock_for = now + lock_time + 1
        lock_acquired = false
        # Acquire the lock.
        if Resque.redis.setnx(lock_key, lock_for)
          lock_acquired = true
        else
          # If we can't acquire the lock, see if it has expired.
          locked_until = Resque.redis.get(lock_key)
          if locked_until
            if locked_until.to_i < now
              locked_until = Resque.redis.getset(lock_key, lock_for)
              if locked_until.nil? or locked_until.to_i < now
                lock_acquired = true
              end
            end
          else
            lock_acquired = true
          end
        end
        if lock_acquired
          begin
            yield
            return true
          ensure
            Resque.redis.del(lock_key)
          end
        else
          return false
        end
      end

    end

  end
end