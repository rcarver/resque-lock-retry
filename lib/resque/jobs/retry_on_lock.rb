module Resque
  module Jobs

    # If you want your job to retry when a lock is encountered, just extend
    # this module.
    module RetryOnLock
      include Locked
      include Retried

      # Use Locked's lock callback.
      def on_lock(*args)
        try_again(*args)
      end

    end
  end
end