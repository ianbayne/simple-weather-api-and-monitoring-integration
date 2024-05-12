require 'rails_helper'

RSpec.describe "Api::V1::Weathers", type: :request, vcr: true do
  describe "GET /show/:city" do
    it "returns http success" do
      city = "Tokyo"
      get "/api/v1/weather/#{city}"

      expect(response).to have_http_status(:success)
    end

    it "returns weather data" do
      city = "Tokyo"
      get "/api/v1/weather/#{city}"

      data = response.parsed_body

      expect(data.keys).to contain_exactly(
        "temperature",
        "humidity",
        "wind_speed",
      )
      expect(data["temperature"]).to be_kind_of(Float)
      expect(data["humidity"]).to be_kind_of(Integer)
      expect(data["wind_speed"]).to be_kind_of(Float)
    end

    it "returns a failure message and status code on fail" do
      allow_any_instance_of(Clients::OpenWeatherMap).to receive(:call)
        .and_return(OpenStruct.new(
          error: 'example error',
          error_status_code: 500
        ))

      city = "Tokyo"
      get "/api/v1/weather/#{city}"

      expect(response).to have_http_status(:internal_server_error)
      expect(response.parsed_body["message"]).to match(/Something went wrong: example error/)
    end
  end
end
