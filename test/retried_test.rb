require File.dirname(__FILE__) + '/test_helper'

class Resque::RetriedJobTest < Test::Unit::TestCase

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint Resque::Plugins::Retried
    end
  end

  def test_can_determine_if_the_exception_is_retried
    assert_equal(true, RetriedOnFailJob.retried_on_exception?(FooError), "FooError is retried")
    assert_equal(true, RetriedOnFailJob.retried_on_exception?(ExtraFooError), "ExtraFooError is retried")
    assert_equal(true, RetriedOnFailJob.retried_on_exception?(BarError), "BarError is retried")
    assert_equal(false, RetriedOnFailJob.retried_on_exception?(StandardError), "StandardError is not retried")
  end

end

class Resque::RetriedJobWithSleepTest < Test::Unit::TestCase

  def setup
    Resque.redis.flushall
  end

  def test_default_seconds_until_retry
    assert_equal 1, RetriedOnFailJob.seconds_until_retry
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

  def test_job_args_are_maintained
    thread = Thread.new { perform_job RetriedOnFailJob, 1, FooError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(FooError, e.class, e.message)
    end
    assert job = Resque.pop(:testqueue)
    assert_equal [1, "FooError"], job["args"]
  end

  def test_job_args_can_be_modified
    thread = Thread.new { perform_job RetriedOnFailWithDifferentArgsJob, 1, FooError }
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(FooError, e.class, e.message)
    end
    assert job = Resque.pop(:testqueue)
    assert_equal [2, "FooError"], job["args"]
  end

end
