# app/controllers/api/v1/weather_controller.rb

class Api::V1::WeatherController < ApplicationController
  # TODO: add support for zip code with country code or direct coordinates forecast
  # Could be separeate api endpoints like /api/v1/weather/zip?zip_code=123&country_code=UK and /api/v1/weather/coordinates?lat=123&lon=123
  def city
    respond_to do |format|
      format.json { render json: city_weather }
      format.html { render html: city_weather }
      format.xml { render xml: city_weather }
    end
  end

  private

  def weather_params
    params.permit(:city, :units, :mode, :lang)
  end

  def city_weather
    @city_weather ||= begin
      geocoding_client = OpenWeatherMap::Clients::Geocoding.new
      weather_client = OpenWeatherMap::Clients::Weather.new

      Weather::City.new(
        city: weather_params[:city],
        units: weather_params[:units],
        mode: weather_params[:mode],
        lang: weather_params[:lang],
        geocoding_client: geocoding_client,
        weather_client: weather_client,
      ).current_weather
    end
  end
end
