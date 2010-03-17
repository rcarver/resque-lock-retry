require File.dirname(__FILE__) + '/test_helper'

class Resque::RetriedOnFailJobTest < Test::Unit::TestCase

  def setup
    Resque.redis.flush_all
  end

  def test_job_enqueues_if_failed_and_exception_allows_retry
    thread = Thread.new { RetriedOnFailJob.perform 1, FooError }
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
    thread = Thread.new { RetriedOnFailJob.perform 1, BarError }
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
    thread = Thread.new { RetriedOnFailJob.perform 1, ExtraFooError }
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
    thread = Thread.new { RetriedOnFailJob.perform 1, StandardError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(StandardError, e.class, e.message)
    end
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "job is NOT enqueued")
  end
end
