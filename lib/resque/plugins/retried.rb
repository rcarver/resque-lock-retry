module Resque
  module Plugins
    module Retried

      # Override in your subclass to control how long to wait before
      # re-queueing the job. Note that the job will block other jobs while
      # this wait occurs. Return nil to perform no delay.
      def sleep_time
        1
      end

      def try_again(*args)
        sleep(sleep_time) if sleep_time
        Resque.enqueue(self, *args)
      end

    end
  end
end