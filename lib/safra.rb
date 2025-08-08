require "zeitwerk"
require "typhoeus"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.setup

module Safra
end

# Backwards compat
module Extractor
  Tap = Safra::Tap
  ResponseWithJson = Safra::ResponseWithJson
end
