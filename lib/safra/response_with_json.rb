module Safra
  class ResponseWithJson < Typhoeus::Response
    def self.from_response response
      res = new(response.options)
      response.request.response = res
      res.request = response.request
      res
    end

    def json
      JSON.parse(body) rescue nil
    end

    def parsed_options
      a = options.dup
      a[:response_body] = JSON.parse(a[:response_body]) rescue a[:response_body]
      a
    end
  end
end
