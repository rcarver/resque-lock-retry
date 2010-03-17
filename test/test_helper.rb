dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true
require 'test/unit'
require 'rubygems'
require 'resque-lock-retry'

#
# make sure we can run redis
#

if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end


#
# start our own redis when the tests start,
# kill it when they end
#

at_exit do
  next if $!

  if defined?(MiniTest)
    exit_code = MiniTest::Unit.new.run(ARGV)
  else
    exit_code = Test::Unit::AutoRunner.run
  end

  pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
  puts "Killing test redis server..."
  `rm -f #{dir}/dump.rdb`
  Process.kill("KILL", pid.to_i)
  exit exit_code
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
Resque.redis = 'localhost:9736'


#
# Job classes for testing
#

class SelfLockJob
  extend ::Resque::Jobs::Locked
  def self.perform_internal(sleep_time)
    sleep sleep_time
  end
end

class LockedJob
  extend ::Resque::Jobs::Locked
  def self.perform_internal(sleep_time)
    sleep sleep_time
  end
  def self.lock(*args)
    "TestLock"
  end
end

class FailJob
  extend ::Resque::Jobs::Locked
  def self.perform_internal(sleep_time)
    sleep sleep_time
    raise "oh no"
  end
  def self.lock(*args)
    "TestLock"
  end
end

class ExecutionExpiresJob
  extend ::Resque::Jobs::Locked
  def self.perform_internal(sleep_time)
    sleep sleep_time
  end
  def self.lock(*args)
    "TestLock"
  end
  def self.lock_time
    1
  end
end

class RetriedOnLockJob
  extend ::Resque::Jobs::Locked
  extend ::Resque::Jobs::RetryOnLock
  @queue = :testqueue
  def self.perform_internal(sleep_time)
    sleep sleep_time
  end
  def self.lock(*args)
    "TestLock"
  end
end

FooError = Class.new(StandardError)
ExtraFooError = Class.new(FooError)
BarError = Class.new(StandardError)

class RetriedOnFailJob
  extend ::Resque::Jobs::RetryOnFail
  @queue = :testqueue
  def self.perform_internal(sleep_time, ex)
    sleep sleep_time
    raise ex
  end
  def self.retried_exceptions
    [FooError, BarError]
  end
  def self.lock(*args)
    "TestLock"
  end
end

class RetriedOnLockAndFail
  extend ::Resque::Jobs::Locked
  extend ::Resque::Jobs::RetryOnLock
  extend ::Resque::Jobs::RetryOnFail
  @queue = :testqueue
  def self.perform_internal(sleep_time, ex)
    sleep sleep_time
    raise ex
  end
  def self.retried_exceptions
    [FooError, BarError]
  end
  def self.lock(*args)
    "TestLock"
  end
end