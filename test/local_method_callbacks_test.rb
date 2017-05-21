require 'test_helper'

class LocalMethodCallbacksTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LocalMethodCallbacks::VERSION
  end

  def test_it_does_something_useful
    assert false
  end

  def test_logger

    logging_array = []

    LocalMethodCallbacks.make_callback(:around) do |env|
      env.decorated.call
    end

  end

end
