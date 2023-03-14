module Extractor

  class Tap
    MAX_RETRIES = 4

    def request_for_batch_size
      if @request_for_batch_size
        @request_for_batch_size
      else
        @request_for_batch_size = [
        self.class.instance_methods(false)
        .find {|m| m.to_s.start_with?('request_for_')}
        .to_s.gsub('request_for_','').to_i,
        1].max
      end
    end

    def initialize initial_value=nil
      @initial_value = initial_value

      if @initial_value.is_a? Array
        @current_value = @initial_value.first
      end
    end

    def next_value
      if @initial_value.is_a? Array
        @initial_value.delete @current_value
        @initial_value.first
      else
        @current_value + 1
      end
    end

    def reached_end? res
      @initial_value.empty?
    end

    def first_value
      nil
    end

    def perform
      @current_value = @current_value || first_value || 1
      retries_count = 0
      while @current_value do
        res = request_for @current_value
        raise "Function request_for() should return a Typhoeus::Response, but returned #{res.class}" if res.class != Typhoeus::Response
        res.options[:response_body] = JSON.parse(res.body) rescue res.body
        response_valid = validate(res) rescue nil
        if response_valid
          Request.insert! build_request_model(res)
          if reached_end?(res)
            @current_value = nil
          else
            @current_value = next_value
          end
        else
          if reached_end?(res)
            @current_value = nil
          elsif retries_count > self.class::MAX_RETRIES
            retries_count += 1
            sleep 2**retries_count
            redo
          else
            puts res.body
            raise "Maximum number of retries reached (#{self.class::MAX_RETRIES})"
          end
        end

      end
      puts "Completed run of #{self.class}"
    end

    private
    def build_request_model typhoeus_response
      {
        extractor_class: self.class,
        base_url: typhoeus_response.request.base_url,
        request_options: typhoeus_response.request.options,
        request_original_options: typhoeus_response.request.original_options,
        response_options: typhoeus_response.options,
        request_cache_key: typhoeus_response.request.cache_key
      }
    end
  end
end
