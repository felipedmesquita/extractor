require "minitest"
require "minitest/autorun"
require_relative "../lib/extractor"

class TapTest < Minitest::Test
  def test_initialization
    Extractor::Tap.new
  end

  # when parameter is not an array, current_value gets incremented by 1
  def test_next_value_when_parameter_is_not_an_array
    tap = Extractor::Tap.new
    assert_equal 148, tap.next_value(current_value: 147, parameter: nil, request_for_batch_size: nil)
  end
end
