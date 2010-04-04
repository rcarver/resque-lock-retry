resque-lock-retry
=================

A Resque plugin. Requires Resque 1.7.1.

Resque-lock-retry is an extension to
[Resque](http://github.com/defunkt/resque) that adds support for ensuring that
only one job runs at a time. In the case of locking conflicts, the job may be
ignored or retried.

This plugin works best in combination with
[resque-scheduler](http://github.com/bvandenbos/resque-scheduler), but it 
isn't required.

Locked jobs
------------

If you want only one instance of your job running at a time, extend
`Resque::Plugins::Locked`.

For example:

    class UpdateNetworkGraph
      extend Resque::Plugins::Locked
      def self.perform(repo_id)
        heavy_lifting
      end
    end

While other UpdateNetworkGraph jobs will be placed on the queue, the `Locked`
class will check `Redis` to see if any others are executing with the same
arguments before beginning. If another is executing the job will be aborted.

If you want to define the key yourself you can override the `lock` class
method in your subclass, e.g.

    class UpdateNetworkGraph
      extend Resque::Plugins::Locked
      # Run only one at a time, regardless of repo_id.
      def self.lock(repo_id)
        "network-graph"
      end
      def self.perform(repo_id)
        heavy_lifting
      end
    end

The above modification will ensure only one job of class `UpdateNetworkGraph`
is running at a time, regardless of the `repo_id`. Normally a job is locked
using a combination of its class name and arguments.

Retried jobs
------------

### Locks

Normally, locked jobs simply abort when a lock is encountered. If you'd like
the job to try again when the lock is lifted, extend `RetryOnLock`.

For example:

    class UpdateNetworkGraph
      extend Resque::Plugins::RetryOnLock
      def self.perform(repo_id)
        heavy_lifting
      end
    end

Now, if the job encounters a lock, the job will be requeued to try again after
a short delay.

### Failures

If you'd like to retry jobs when certain exceptions happen, use `RetryOnFail`.
Then, define the types of exceptions that are ok to retry on.

For example:

    class UpdateNetworkGraph
      extend Resque::Plugins::RetryOnFail
      def self.perform(repo_id)
        heavy_lifting
      end
      def self.retried_exceptions
        [NetworkError]
      end
    end

Now, if a `NetworkError` (or subclass) exception is thrown while performing
the job, it will be required after a short delay.

### Retry strategies

Retrying comes in two flavors:

1. [resque-scheduler](http://github.com/bvandenbos/resque-scheduler) If
Resque responds to `enqueue_in`, the job will be scheduled to perform again in
the 5 seconds.

2. `sleep` If Resque does not respond to `enqueue_in`, then we simply sleep
for 1 second before enqueing the job. This method is NOT recommended because
it will block your worker.

To change how long to wait until the job is retried, just override
`seconds_until_retry`

    class UpdateNetworkGraph
      extend Resque::Plugins::RetryOnLock
      def self.perform(repo_id)
        heavy_lifting
      end
      def self.seconds_until_retry
        100
      end
    end

### Bonus

Retries may be combined. For example:

    class UpdateNetworkGraph
      extend Resque::Plugins::RetryOnLock
      extend Resque::Plugins::RetryOnFail
      ...
    end

Contributing
------------

For bugs or suggestions, please just open an issue in github.
