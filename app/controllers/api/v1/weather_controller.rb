# app/controllers/api/v1/weather_controller.rb

class Api::V1::WeatherController < ApplicationController
  rescue_from Weather::Errors::InvalidTokenError, with: :render_invalid_token_error
  rescue_from Weather::Errors::CityNotFoundError, with: :render_city_not_found_error
  rescue_from Weather::Errors::WeatherFetchError, with: :render_weather_fetch_error

  # TODO: add support for zip code with country code or direct coordinates forecast
  # Could be separeate api endpoints like /api/v1/weather/zip?zip_code=123&country_code=UK and /api/v1/weather/coordinates?lat=123&lon=123
  def city
    start_time = Time.now

    city_weather

    response_time = Time.now - start_time
    WEATHER_REQUESTS_COUNTER.observe(1)
    WEATHER_RESPONSE_TIME.observe(response_time)

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
    # add average response time metric with opentelemetry


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

  def render_invalid_token_error(error)
    render json: { error: error.message }, status: :unauthorized
  end

  def render_city_not_found_error(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_weather_fetch_error(error)
    render json: { error: error.message }, status: :bad_request
  end
end
