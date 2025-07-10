require "zeitwerk"
require "typhoeus"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.setup

module Safra

end
