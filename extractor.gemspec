Gem::Specification.new do |s|
  s.name = "extractor"
  s.version = "0.0.1"
  s.summary = "Extract data from APIs with mininal configuration"
  s.authors = ["Felipe Mesquita"]
  s.email = "felipemesquita@hey.com"
  s.homepage = "https://github.com/felipedmesquita/extractor"
  s.license = "MIT"

  s.files = Dir["lib/**/*"]

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "railties", ">= 6"
  s.add_dependency "activerecord", ">= 6"
  s.add_dependency "zeitwerk"
  s.add_dependency "typhoeus"
  s.add_development_dependency "minitest", ">= 5.0"
end
