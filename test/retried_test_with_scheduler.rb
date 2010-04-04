require File.dirname(__FILE__) + '/test_helper'

module Resque
  def self.enqueue_in(seconds, klass, *args)
    @last_enqueued_in = [seconds, klass, *args]
  end
  def self.last_enqueued_in
    @last_enqueued_in
  end
end

class Resque::RetriedJobWithResqueSchedulerTest < Test::Unit::TestCase

  def setup
    Resque.redis.flush_all
  end

  def test_default_seconds_until_retry
    assert_equal 5, RetriedOnFailJob.seconds_until_retry
  end

  def test_job_enqueues_in_time_if_failed_and_exception_allows_retry
    thread = Thread.new { perform_job RetriedOnFailJob, 0, FooError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(FooError, e.class, e.message)
    end
    assert_equal([5, RetriedOnFailJob, 0, FooError], Resque.last_enqueued_in)
  end

end