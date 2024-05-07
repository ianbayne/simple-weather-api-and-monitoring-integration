class GetWeatherData
  include Callable

  def initialize(city)
    @city = city
  end

  def call
    @result = Clients::OpenWeatherMap.call(@city)
    OpenStruct.new(
      success?: success?,
      payload: @result[:payload],
      error: @result[:error],
      error_status_code: error_status_code
    )
  end

  def success?
    @result[:error].nil?
  end

  def error_status_code
    @result[:error_status_code]
  end
end