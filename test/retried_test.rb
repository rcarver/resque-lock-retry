require File.dirname(__FILE__) + '/test_helper'

class Resque::RetriedJobTest < Test::Unit::TestCase

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint Resque::Plugins::Retried
    end
  end

end