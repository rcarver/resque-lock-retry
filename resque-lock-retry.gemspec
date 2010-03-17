# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{resque-lock-retry}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Carver"]
  s.date = %q{2010-03-17}
  s.email = %q{ryan@typekit.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "README.markdown",
     "Rakefile",
     "VERSION",
     "lib/resque-lock-retry.rb",
     "lib/resque/jobs/locked.rb",
     "lib/resque/jobs/retried.rb",
     "test/locked_test.rb",
     "test/redis-test.conf",
     "test/retried_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/rcarver/resque-lock-retry}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Adds lockable and retryable jobs to Resque.}
  s.test_files = [
    "test/locked_test.rb",
     "test/retried_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
