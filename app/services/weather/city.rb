# app/services/weather/city.rb

module Weather
  class City
    ALLOWED_MODES = %w[json xml html].freeze
    ALLOWED_UNITS = %w[standard metric imperial].freeze
    ALLOWED_LANGS = %w[en es de fr ja ru it pt].freeze

    CACHE_NAMESPACE = :weather_city_current_weather

    DEFAULT_UNITS = "standard"
    DEFAULT_MODE = "json"
    DEFAULT_LANG = "en"

    def initialize(city:, units: nil, mode: nil, lang: nil, geocoding_client:, weather_client:)
      @city = city
      @units = units
      @mode = mode
      @lang = lang
      @geocoding_client = geocoding_client
      @weather_client = weather_client
    end

    def current_weather
      with_telemetry(method: __method__) do
        raise Errors::WeatherFetchError, "City name can't be blank" if @city.blank?

        @mode = DEFAULT_MODE unless @mode.in?(ALLOWED_MODES)
        @units = DEFAULT_UNITS unless @units.in?(ALLOWED_UNITS)
        @lang = DEFAULT_LANG unless @lang.in?(ALLOWED_LANGS)

        Caching.fetch(cache_key, namespace: CACHE_NAMESPACE) do
          code, body = @geocoding_client.direct(q: @city)

          raise Errors::InvalidTokenError, "Can't access OpenWeatherMap API" if code == 401

          geolocation = JSON.parse(body).first

          raise Errors::CityNotFoundError, "Can't locate the city" unless geolocation && code == 200

          code, body = @weather_client.current_weather(lat: geolocation["lat"], lon: geolocation["lon"], units: @units, mode: @mode, lang: @lang)

          raise Errors::InvalidTokenError, "Can't access OpenWeatherMap API" if code == 401
          raise Errors::WeatherFetchError, "Can't get weather information" unless code == 200

          body
        end
      end
    end

    private

    def cache_key
      { city: @city.upcase, units: @units, mode: @mode, lang: @lang }
    end

    def telemetry_tracer
      @telemetry_tracer ||= OpenTelemetry.tracer_provider.tracer('Weather::City')
    end

    def with_telemetry(method:, &block)
      telemetry_tracer.in_span(method, &block)
    end
  end
end
