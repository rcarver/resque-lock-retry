module Resque
  module Jobs

    # If you want your job to retry when a lock is encountered, just extend
    # this module.
    module RetryOnLock
      include Locked
      include Retried

      # Do not override - this is where the magic happens. Instead provide
      # your own `perform_internal` class level method.
      def perform(*args)
        super or try_again(*args)
      end

    end
  end
end