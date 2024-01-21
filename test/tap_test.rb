require "minitest"
require "minitest/autorun"
require_relative "../lib/extractor"

class TapTest < Minitest::Test
  def test_initialization
    Extractor::Tap.new
  end

  def test_next_value
    tap = Extractor::Tap.new
    assert_equal 2, tap.next_value(current_value: 1, parameter: nil, request_for_batch_size: 1)
  end
end
