resque-lock-retry
=================

Resque-lock-retry is an extension to [Resque](http://github.com/defunkt/resque)
that adds support for ensuring that only one job runs at a time. In the case
of locking conflicts, the job may be ignored or retried.
