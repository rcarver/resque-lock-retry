require File.dirname(__FILE__) + '/test_helper'

class Resque::CombinedTest < Test::Unit::TestCase

  def setup
    Resque.redis.flush_all
  end

  def test_lock_on_fail_with_lock_on_retry
    thread = Thread.new { RetriedOnLockAndFail.perform 1, FooError }
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
    begin
      thread.join
      assert(false, "Should have raised an exception")
    rescue StandardError => e
      assert_equal(FooError, e.class)
    end
    assert_equal(false, Resque.redis.exists("locked:TestLock"), "job cleared the lock")
    assert_equal(1, Resque.redis.llen("queue:testqueue").to_i, "job is enqueued")
  end

end
