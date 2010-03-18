module Resque
  module Jobs

    # If you want your job to retry when an exception is encountered, just
    # extend this module. Override +retried_exceptions+ to return an array
    # of the exceptions that are ok to retry on. There are no defaults.
    module RetryOnFail
      include Retried

      # Convenience method to test whether your class will retry on a given
      # exception type.
      def retried_on_exception?(ex)
        !! retried_exceptions.any? { |e| e >= ex }
      end

      # Override in your subclass to control how long to wait before
      # re-queueing the job when a lock is encountered. Note that the job will
      # block other jobs while this wait occurs. Return nil to perform no
      # delay.
      def retried_exceptions
        []
      end

      # Do not override - this is where the magic happens. Instead provide
      # your own `perform_internal` class level method.
      def on_failure(e, *args)
        try_again(*args) if retried_on_exception?(e.class)
      end

    end
  end
end