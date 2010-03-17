$LOAD_PATH.unshift 'lib'

task :default => :test

desc "Run tests"
task :test do
  # Don't use the rake/testtask because it loads a new
  # Ruby interpreter - we want to run tests with the current
  # `rake` so our library manager still works
  Dir['test/*_test.rb'].each do |f|
    require f
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "resque-lock-retry"
    gemspec.summary = "Adds lockable and retryable jobs to Resque."
    gemspec.email = "ryan@typekit.com"
    gemspec.homepage = "http://github.com/rcarver/resque-lock-retry"
    gemspec.authors = ["Ryan Carver"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end