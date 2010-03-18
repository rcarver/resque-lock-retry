require File.dirname(__FILE__) + '/test_helper'

class Resque::LockedJobTest < Test::Unit::TestCase

  def setup
    Resque.redis.flush_all
  end

  def test_job_locks_and_unlocks
    thread = Thread.new { perform_job LockedJob, 1 }
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
    thread.join
    assert_equal(false, Resque.redis.exists("locked:TestLock"), "job cleared the lock")
  end

  def test_existing_lock_stops_job_from_performing
    thread = Thread.new { perform_job LockedJob, 1 }
    assert_equal(false, perform_job(LockedJob, 0), "job cannot run")
    thread.join
    assert_equal(true, perform_job(LockedJob, 0), "job can run")
  end

  def test_lock_recovers_after_lock_timeout
    thread = Thread.new { perform_job ExecutionExpiresJob, 4 }
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
    assert_equal(false, perform_job(LockedJob, 0), "job cannot run")
    sleep 3
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "lock still exists")
    assert_equal(true, perform_job(LockedJob, 0), "job can run")
    assert_equal(false, Resque.redis.exists("locked:TestLock"), "job cleared the stale lock")
    thread.join
  end

  def test_lock_is_removed_when_job_fails
    thread = Thread.new { perform_job FailJob, 1 }
    assert_equal(true, Resque.redis.exists("locked:TestLock"), "job set the lock")
    begin
      thread.join
    rescue StandardError => e
      assert_equal("oh no", e.message, "job threw an exception")
    end
    assert_equal(false, Resque.redis.exists("locked:TestLock"), "job cleared the lock")
  end

  def test_job_name_and_args_are_default_lock
    thread = Thread.new { perform_job SelfLockJob, 1 }
    assert_equal(true, Resque.redis.exists("locked:SelfLockJob-1"), "job set the lock")
    thread.join
  end

  def test_can_determine_if_job_is_locked
    thread = Thread.new { perform_job(SelfLockJob, 1) }
    assert_equal(true, SelfLockJob.locked?(1), "job is locked")
    assert_equal(false, SelfLockJob.locked?(2), "job with other args is not locked")
    thread.join
    assert_equal(false, SelfLockJob.locked?(1), "job is not locked")
  end

end