# app/controllers/api/v1/weather_controller.rb

class Api::V1::WeatherController < ApplicationController
  def city
    respond_to do |format|
      format.json { render json: city_weather }
      format.html { render html: city_weather.to_s }
      format.xml { render xml: city_weather.to_xml }
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
