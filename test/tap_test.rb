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

  # when parameter is an array
  def test_next_value_when_parameter_is_an_array
    tap = Extractor::Tap.new

    items_to_be_extracted = [1, 2, 3, 4]
    batch_size = 2
    current_batch = [1, 2]
    expected_next_batch = [3, 4]

    assert_equal expected_next_batch, tap.next_value(current_value: current_batch, parameter: items_to_be_extracted, request_for_batch_size: batch_size)
  end
end
