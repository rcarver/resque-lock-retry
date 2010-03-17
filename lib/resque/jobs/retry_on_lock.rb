module Resque
  module Jobs
    module RetryOnLock
      include Retried

      # Do not override - this is where the magic happens. Instead provide
      # your own `perform_without_lock` class level method.
      def perform(*args)
        super or try_again(*args)
      end

    end
  end
end