class Request < ApplicationRecord
  class << self
    Dir.glob('app/extractors/**/*').map {|t| t.scan /extractors\/(.*_tap)\.rb/}.flatten.each do |name|
      define_method(name) {where extractor_class: name.classify}
    end

    def create_from_response typhoeus_response
      res = Extractor::ResponseWithJson.from_response typhoeus_response
      create!({
        extractor_class: self.class,
        base_url: res.request.base_url,
        request_options: res.request.options,
        request_original_options: res.request.original_options,
        response_options: res.parsed_options,
        request_cache_key: res.request.cache_key
      })
    end
  end
end
