require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "resque-lock-retry"
    gemspec.summary = "Adds lockable and retryable jobs to Resque."
    gemspec.email = "ryan@typekit.com"
    gemspec.homepage = "http://github.com/rcarver/resque-lock-retry"
    gemspec.authors = ["Ryan Carver"]

    gemspec.add_dependency "resque", ">=0.7.1"
    gemspec.add_development_dependency "jeweler"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
