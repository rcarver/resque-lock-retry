module Resque
  module Jobs
    class Retried < Locked

      def self.perform(*args)
        super or try_again(*args)
      end

      def self.sleep_time
        1
      end

      def self.try_again(*args)
        sleep(sleep_time) if sleep_time
        Resque.enqueue(self, *args)
      end

    end
  end
end