module Resque
  module Jobs
    module PerformInternal

      def perform(*args)
        perform_internal(*args)
      end

    end
  end
end