module Resque
  module Plugins
    module Retried

      # Override in your subclass to control how long to wait before
      # performing this job again. Retrying comes in two flavors:
      #
      # 1. `ResqueScheduler`
      #    If Resque responds to `enqueue_in`, the job will be scheduled to
      #    perform again in the defined number of seconds.
      #
      # 2. `sleep`
      #    If Resque does not respond to `enqueue_in`, then we simply sleep
      #    for the defined number of seconds before enqueing the job. This
      #    method is NOT recommended because it will block your worker.
      #
      # Return nil to perform no delay.
      def seconds_until_retry
        Resque.respond_to?(:enqueue_in) ? 5 : 1
      end

      def try_again(*args)
        if Resque.respond_to?(:enqueue_in)
          Resque.enqueue_in(seconds_until_retry || 0, self, *args)
        else
          sleep(seconds_until_retry) if seconds_until_retry
          Resque.enqueue(self, *args)
        end
      end

    end
  end
end