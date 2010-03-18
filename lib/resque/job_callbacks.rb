module Resque
  class Job
    def perform
      job_args = args || []

      # Execute before_perform hook and abort if it returns false
      if payload_class.respond_to?(:before_perform)
        result = payload_class.before_perform(*job_args)
        return false if result == false
      end

      begin
        # Execute the job. Do it in an around_perform hook if available.
        if payload_class.respond_to?(:around_perform)
          result = payload_class.around_perform(*job_args) do
            payload_class.perform(*job_args)
          end
        else
          result = true
          payload_class.perform(*job_args)
        end

        # Execute after_perform hook
        if payload_class.respond_to?(:after_perform)
          payload_class.after_perform(*job_args)
        end

        # Return true unless the around_perform hook returned false
        return result
      rescue Object => e
        # If an exception occurs during the job execution, look for an
        # on_failure hook then re-raise.
        if payload_class.respond_to?(:on_failure)
          payload_class.on_failure(e, *job_args)
        end
        raise
      end
    end
  end
end