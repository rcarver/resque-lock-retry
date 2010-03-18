require File.dirname(__FILE__) + '/test_helper'

class Resque::RetriedOnLockJobTest < Test::Unit::TestCase

  def setup
    Resque.redis.flush_all
  end

  def test_job_performs_normally
    thread = Thread.new { perform_job RetriedOnLockJob, 1 }
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
    thread.join
    assert_equal(false, Resque.redis.exists("locked:TestLock"), "job cleared the lock")
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
  end
  # 
  # def test_job_enqueues_if_lock_encountered
  #   thread = Thread.new { perform_job RetriedOnLockJob, 1 }
  #   assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
  #   assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
  #   perform_job RetriedOnLockJob, 1
  #   assert_equal(1, Resque.redis.llen("queue:testqueue").to_i, "job is enqueued")
  #   thread.join
  # end

  def test_job_enqueues_after_waiting_if_lock_encountered
    thread1 = Thread.new { perform_job RetriedOnLockJob, 1 }
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is empty")
    thread2 = Thread.new { perform_job RetriedOnLockJob, 1 }
    sleep 1
    assert_equal(0, Resque.redis.llen("queue:testqueue").to_i, "queue is still empty")
    thread2.join
    assert_equal(1, Resque.redis.llen("queue:testqueue").to_i, "job is enqueued")
    thread1.join
  end

end
