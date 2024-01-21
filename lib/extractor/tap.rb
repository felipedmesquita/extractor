module Extractor
  class Tap
    MAX_RETRIES = 4
    SUPPORTED_ON_MAX_RETRIES_VALUES = [:fail, :save_to_errors, :skip_silently]
    ON_MAX_RETRIES = :fail

    def initialize parameter = nil, auth: {}
      check_on_max_retries
      @auth = auth
      if @auth.present? and @auth[:account_id].blank?
        puts "WARNING: No account_id provided in 'auth:' parameter for #{self.class}"
      end
      @parameter = parameter

      @request_for_method_name =
        self.class.instance_methods(false)
          .find { |m| m.to_s.start_with?("request_for_") } || :request_for

      @request_for_batch_size = [
        @request_for_method_name
          .to_s.gsub("request_for_", "").to_i,
        1
      ].max

      @current_value = if @parameter.is_a? Array
        @parameter.first @request_for_batch_size
      else
        first_value || 1
      end
    end

    def next_value(current_value:, parameter:, request_for_batch_size:)
      if current_value.is_a? Array
        parameter -= current_value
        parameter.first request_for_batch_size
      else
        current_value + 1
      end
    end

    def reached_end? res
      @parameter.empty?
    end

    def first_value
      nil
    end

    def perform
      retries_count = 0
      while @current_value.present?
        original_response = send(@request_for_method_name, (@request_for_batch_size == 1) ? begin
          @current_value.first
        rescue
          @current_value
        end : @current_value)
        raise "Function request_for() should return a Typhoeus::Response, but returned #{original_response.class}" if original_response.class != Typhoeus::Response
        res = ResponseWithJson.from_response original_response
        response_valid = begin
          validate(res)
        rescue
          nil
        end
        if response_valid
          @last_response = res
          Request.insert! build_request_model(res)
          retries_count = 0
          @current_value = if begin
            reached_end?(res)
          rescue
            false
          end
            nil
          else
            next_value(current_value: @current_value, parameter: @parameter, request_for_batch_size: @request_for_batch_size)
          end
        elsif begin
          reached_end?(res)
        rescue
          false
        end
          @current_value = nil
        elsif retries_count < self.class::MAX_RETRIES
          retries_count += 1
          puts "sleep #{2**retries_count} then will retry #{"again" if retries_count > 1}"
          sleep(2**retries_count)
          redo
        else
          case self.class::ON_MAX_RETRIES
          when :fail
            raise "Maximum number of retries reached (#{self.class::MAX_RETRIES})"
          when :save_to_errors
            Request.insert! build_request_model_for_error(res)
          when :skip_silently
            puts "skiped on value #{@current_value}"
          end
          @current_value = next_value(current_value: @current_value, parameter: @parameter, request_for_batch_size: @request_for_batch_size)
          retries_count = 0
        end

      end
      puts "Completed run of #{self.class}"
    end

    private

    def build_request_model typhoeus_response
      {
        extractor_class: self.class,
        account_id: @auth[:account_id],
        base_url: typhoeus_response.request.base_url,
        request_options: typhoeus_response.request.options,
        request_original_options: typhoeus_response.request.original_options,
        response_options: typhoeus_response.parsed_options,
        request_cache_key: typhoeus_response.request.cache_key
      }
    end

    def build_request_model_for_error typhoeus_response
      {
        extractor_class: "#{self.class}_errors",
        account_id: @auth[:account_id],
        base_url: typhoeus_response.request.base_url,
        request_options: typhoeus_response.request.options,
        request_original_options: typhoeus_response.request.original_options,
        response_options: typhoeus_response.parsed_options,
        request_cache_key: typhoeus_response.request.cache_key
      }
    end

    def check_on_max_retries
      unless SUPPORTED_ON_MAX_RETRIES_VALUES.include? self.class::ON_MAX_RETRIES
        raise "Unsuported ON_MAX_RETRIES value #{self.class::ON_MAX_RETRIES} supported values are #{SUPPORTED_ON_MAX_RETRIES_VALUES}"
      end
    end
  end
end
