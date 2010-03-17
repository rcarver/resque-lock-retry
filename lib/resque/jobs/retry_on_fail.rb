module Resque
  module Jobs
    module RetryOnFail
      include Retried

      # Override in your subclass to control how long to wait before
      # re-queueing the job when a lock is encountered. Note that the job will
      # block other jobs while this wait occurs. Return nil to perform no
      # delay.
      def retried_exceptions
        []
      end

      # Do not override - this is where the magic happens. Instead provide
      # your own `perform_internal` class level method.
      def perform(*args)
        begin
          super
        rescue Exception => ex
          try_again(*args) if retried_exceptions.any? { |e| ex.is_a?(e) }
          raise
        end
      end

    end
  end
end