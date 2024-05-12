class GetWeatherData
  include Callable

  def initialize(city, client = Clients::OpenWeatherMap)
    @city = city
    @client = client
  end

  def call
    result = @client.call(@city)
    
    if result[:error].nil?
      OpenStruct.new(
        success?: true,
        payload: result[:payload],
      )
    else
      OpenStruct.new(
        success?: false,
        error: result[:error],
        error_status_code: result[:error_status_code]
      )
    end
  end
end