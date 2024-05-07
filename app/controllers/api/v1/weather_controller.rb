class Api::V1::WeatherController < ApplicationController
  def show
    city = params[:city]
    result = GetWeatherData.call(city)
    if result.success?
      render json: result.payload, status: :ok
    else
      render json: {
        message: "Something went wrong: #{result.error}",
      }, status: result.error_status_code
    end
  end
end
