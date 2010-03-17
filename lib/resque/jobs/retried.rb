module Resque
  module Jobs
    module Retried
      include PerformInternal

      # Override in your subclass to control how long to wait before
      # re-queueing the job when a lock is encountered. Note that the job will
      # block other jobs while this wait occurs. Return nil to perform no
      # delay.
      def sleep_time
        1
      end

      # When a lock is encountered, the job is requeued.
      def try_again(*args)
        sleep(sleep_time) if sleep_time
        Resque.enqueue(self, *args)
      end

    end
  end
end