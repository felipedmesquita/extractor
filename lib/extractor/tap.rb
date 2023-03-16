class Extractor::Tap

  MAX_RETRIES = 4
  SUPPORTED_ON_MAX_RETRIES_VALUES = [:fail, :save_to_errors, :skip_silently]
  ON_MAX_RETRIES = :fail

  def initialize parameter=nil, auth:{}
    check_on_max_retries
    @auth = auth
    @parameter = parameter

    @request_for_method_name =
      self.class.instance_methods(false)
      .find {|m| m.to_s.start_with?('request_for_')} || :request_for

    @request_for_batch_size = [
      @request_for_method_name
      .to_s.gsub('request_for_','').to_i,
      1].max

    if @parameter.is_a? Array
      @current_value = @parameter.first @request_for_batch_size
    else
      @current_value = first_value || 1
    end
  end

  def next_value
    if @current_value.is_a? Array
      @parameter -= @current_value
      @parameter.first @request_for_batch_size
    else
      @current_value + 1
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
    while @current_value.present? do
      #binding.irb
      res = send(@request_for_method_name, @request_for_batch_size == 1 ? (@current_value.first rescue @current_value) : @current_value)
      raise "Function request_for() should return a Typhoeus::Response, but returned #{res.class}" if res.class != Typhoeus::Response
      #res.options[:response_body] = JSON.parse(res.body) rescue res.body
      def res.json = JSON.parse(body) rescue nil
      response_valid = validate(res) rescue nil
      if response_valid
        @last_response = res
        Request.insert! build_request_model(res)
        retries_count = 0
        if (reached_end?(res) rescue false)
          @current_value = nil
        else
          @current_value = next_value
        end
      else
        if (reached_end?(res) rescue false)
          @current_value = nil
        elsif retries_count < self.class::MAX_RETRIES
          retries_count += 1
          puts "sleep #{(2**retries_count)} then will retry #{'again' if retries_count > 1}"
          sleep (2**retries_count)
          redo
        else
          case self.class::ON_MAX_RETRIES
          when :fail
            raise "Maximum number of retries reached (#{self.class::MAX_RETRIES})"
          when :save_to_errors
            Request.insert! build_request_model_for_error(res)
            @current_value = next_value
          when :skip_silently
            @current_value = next_value
          end
        end
      end

    end
    puts "Completed run of #{self.class}"
  end

  private
  def build_request_model typhoeus_response
    typhoeus_response.options[:response_body] = JSON.parse(typhoeus_response.body) rescue typhoeus_response.body
    {
      extractor_class: self.class,
      base_url: typhoeus_response.request.base_url,
      request_options: typhoeus_response.request.options,
      request_original_options: typhoeus_response.request.original_options,
      response_options: typhoeus_response.options,
      request_cache_key: typhoeus_response.request.cache_key
    }
  end

  def build_request_model_for_error typhoeus_response
    typhoeus_response.options[:response_body] = JSON.parse(typhoeus_response.body) rescue typhoeus_response.body
    {
      extractor_class: "#{self.class}_errors",
      base_url: typhoeus_response.request.base_url,
      request_options: typhoeus_response.request.options,
      request_original_options: typhoeus_response.request.original_options,
      response_options: typhoeus_response.options,
      request_cache_key: typhoeus_response.request.cache_key
    }
  end

  def check_on_max_retries
    unless SUPPORTED_ON_MAX_RETRIES_VALUES.include? self.class::ON_MAX_RETRIES
      raise "Unsuported ON_MAX_RETRIES value #{self.class::ON_MAX_RETRIES} supported values are #{SUPPORTED_ON_MAX_RETRIES_VALUES}"
    end
  end
end
