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

