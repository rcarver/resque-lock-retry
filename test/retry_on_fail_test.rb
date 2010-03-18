require File.dirname(__FILE__) + '/test_helper'

class Resque::RetriedOnFailJobTest < Test::Unit::TestCase

  def setup
    Resque.redis.flush_all
  end

  def test_job_enqueues_if_failed_and_exception_allows_retry
    thread = Thread.new { perform_job RetriedOnFailJob, 1, FooError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(FooError, e.class, e.message)
    end
    assert_equal(1, Resque.redis.llen("queue:testqueue").to_i, "job is enqueued")
  end

  def test_job_enqueues_if_failed_and_other_exception_allows_retry
    thread = Thread.new { perform_job RetriedOnFailJob, 1, BarError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(BarError, e.class, e.message)
    end
    assert_equal(1, Resque.redis.llen("queue:testqueue").to_i, "job is enqueued")
  end

  def test_job_enqueues_if_failed_and_exception_superclass_allows_retry
    thread = Thread.new { perform_job RetriedOnFailJob, 1, ExtraFooError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(ExtraFooError, e.class, e.message)
    end
    assert_equal(1, Resque.redis.llen("queue:testqueue").to_i, "job is enqueued")
  end

  def test_job_does_not_enqueues_if_failed_and_exception_does_not_allow_retry
    thread = Thread.new { perform_job RetriedOnFailJob, 1, StandardError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(StandardError, e.class, e.message)
    end
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "job is NOT enqueued")
  end

  def test_can_determine_if_the_exception_is_retried
    assert_equal(true, RetriedOnFailJob.retried_on_exception?(FooError), "FooError is retried")
    assert_equal(true, RetriedOnFailJob.retried_on_exception?(ExtraFooError), "ExtraFooError is retried")
    assert_equal(true, RetriedOnFailJob.retried_on_exception?(BarError), "BarError is retried")
    assert_equal(false, RetriedOnFailJob.retried_on_exception?(StandardError), "StandardError is not retried")
  end
end
