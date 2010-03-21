module Resque

  DontPerform = Class.new(StandardError)

  class Job

    def perform
      job_args = args || []
      job_was_performed = false

      begin
        # Execute before_perform hook. Abort the job gracefully if
        # Resque::DontPerform is raised.
        begin
          if payload_class.respond_to?(:before_perform)
            payload_class.before_perform(*job_args)
          end
        rescue DontPerform
          return false
        end

        # Execute the job. Do it in an around_perform hook if available.
        if payload_class.respond_to?(:around_perform)
          payload_class.around_perform(*job_args) do
            payload_class.perform(*job_args)
            job_was_performed = true
          end
        else
          payload_class.perform(*job_args)
          job_was_performed = true
        end

        # Execute after_perform hook
        if payload_class.respond_to?(:after_perform)
          payload_class.after_perform(*job_args)
        end

        # Return true if the job was performed
        return job_was_performed

      # If an exception occurs during the job execution, look for an
      # on_failure hook then re-raise.
      rescue Object => e
        if payload_class.respond_to?(:on_failure)
          payload_class.on_failure(e, *job_args)
        end
        raise
      end
    end
  end
end