require 'open-uri'

class Clients::OpenWeatherMap
  include Callable

  API_URL = "https://api.openweathermap.org/data/2.5/weather"

  def initialize(city)
    @city = city
  end

  def call
    get_weather_data
  end

  private

  def get_weather_data
    api_key = Rails.application.credentials.open_weather_map.api_key

    uri = URI.parse(API_URL)
    params = { q: @city, appid: api_key}
    uri.query = URI.encode_www_form(params)

    str = uri.open.read
    data = JSON.parse(str) # TODO: What should happen if the str cannot be parsed by JSON? Rescue from JSON::ParserError?
    temperature = data.dig("main", "temp")
    humidity = data.dig("main", "humidity")
    wind_speed = data.dig("wind", "speed")

    { payload: { temperature:, humidity:, wind_speed: }}
  rescue OpenURI::HTTPError => error
    { error:, error_status_code: error.io.status[0] }
  end
end