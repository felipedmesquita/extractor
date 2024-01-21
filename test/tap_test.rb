require "minitest"
require "minitest/autorun"
require_relative "../lib/extractor"

class TapTest < Minitest::Test
  def test_initialization
    Extractor::Tap.new
  end
end
