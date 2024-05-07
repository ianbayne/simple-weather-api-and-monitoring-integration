class PerformanceMonitor
  def initialize(app)
    @app = app
    @response_times = []
    @request_timestamps = []
  end

  def call(env)
    request = Rack::Request.new(env)
    
    pattern = %r{/api/v1/weather/\S+}
    if request.path.match?(pattern)
      status = headers = response = nil

      trace_average_response_time { status, headers, response = @app.call(env) }
      trace_requests_per_minute

      [status, headers, response]
    else
      @app.call(env)
    end
  end

  private

  #  Note: The following does not actually trace the average server response time. It traces:
  #  - the time spent in ruby to send the request
  #  - the network time of the request
  #  - the server's response time
  #  - the network time of the response
  #  - the time spent in ruby to process the response
  #  If the actual average server response time is required, another method of doing so will 
  #  need to be investigated (response headers?).
  def trace_average_response_time(&block)
    tracer = OpenTelemetry.tracer_provider.tracer("tablecheck-customer-reliability-take-home")
    tracer.in_span("api_requests") do |span|
      start_time = Time.current
      yield
      end_time = Time.current
      duration = end_time - start_time
      @response_times << duration
      average_response_time = @response_times.sum / @response_times.length
      span.set_attribute('api_requests.average_response_time', average_response_time)
    end
  end

  def trace_requests_per_minute
    tracer = OpenTelemetry.tracer_provider.tracer("tablecheck-customer-reliability-take-home")
    tracer.in_span("api_requests") do |span|
      @request_timestamps << Time.current
      @request_timestamps.reject! { |timestamp| timestamp < (Time.current - 60) }
      requests_per_minute = @request_timestamps.length
      span.set_attribute('api_requests.requests_per_minute', requests_per_minute)
    end
  end
end