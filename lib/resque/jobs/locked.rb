module Resque
  module Jobs

    # If you want only one instance of your job running at a time, extend
    # this module.
    #
    # For example:
    #
    # class UpdateNetworkGraph
    #   extend Resque::Jobs::Locked
    #   def self.perform(repo_id)
    #     heavy_lifting
    #   end
    # end
    #
    # While other UpdateNetworkGraph jobs will be placed on the queue, the
    # Locked class will check Redis to see if any others are executing with
    # the same arguments before beginning. If another is executing the job
    # will be aborted.
    #
    # If you want to define the key yourself you can override the `lock` class
    # method in your subclass, e.g.
    #
    # class UpdateNetworkGraph
    #   extend Resque::Jobs::Locked
    #   # Run only one at a time, regardless of repo_id.
    #   def self.lock(repo_id)
    #     "network-graph"
    #   end
    #
    #   def self.perform(repo_id)
    #     heavy_lifting
    #   end
    # end
    #
    #
    # The above modification will ensure only one job of class
    # UpdateNetworkGraph is running at a time, regardless of the repo_id.
    # Normally a job is locked using a combination of its class name and
    # arguments.
    module Locked

      # Convenience method to determine if a lock exists for this job, not
      # used internally.
      def locked?(*args)
        Resque.redis.exists "locked:#{lock(*args)}"
      end

      # Override in your subclass to control the lock key. It is passed the
      # same arguments as `perform`, that is, your job's payload.
      def lock(*args)
        "#{name}-#{args.to_s}"
      end

      # Override in your subclass to control how long the lock exists. Under
      # normal circumstances, the lock will be removed when the job ends. If
      # this doesn't happen, the lock will be removed after this many seconds.
      def lock_time
        60
      end

      # Locking algorithm: http://code.google.com/p/redis/wiki/SetnxCommand
      def around_perform_lock(*args)
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
          ensure
            Resque.redis.del(lock_key)
          end
        else
          on_lock(*args) if respond_to?(:on_lock)
        end
      end
    end

  end
end