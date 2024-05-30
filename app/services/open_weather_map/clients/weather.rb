# frozen_string_literal: true

module OpenWeatherMap
  module Clients
    class Weather < BaseClient
      base_uri "https://api.openweathermap.org/data/2.5"

      CACHE_NAMESPACE = :openweathermap_current_weather

      ALLOWED_MODES = %w[json xml html].freeze
      ALLOWED_UNITS = %w[standard metric imperial].freeze
      ALLOWED_LANGS = %w[en es de fr ja ru it pt].freeze

      DEFAULT_UNITS = "standard"
      DEFAULT_MODE = "json"
      DEFAULT_LANG = "en"

      def current_weather(lat:, lon:, units: nil, mode: nil, lang: nil)
        units = DEFAULT_UNITS unless units.in? ALLOWED_UNITS
        mode = DEFAULT_MODE unless mode.in? ALLOWED_MODES
        lang = DEFAULT_LANG unless lang.in? ALLOWED_LANGS

        query = { lat: lat, lon: lon, units: units, mode: mode, lang: lang, appid: @app_id }

        cache_key = query.except(:appid)

        Caching.fetch(cache_key, namespace: CACHE_NAMESPACE) do
          response = get("/weather", query:)

          break [response.code, response.body] unless response.success?

          [response.code, response.body]
        end
      end

      private

      def cache_params
        { namespace: CACHE_NAMESPACE, expires_in: 10.minutes }
      end
    end
  end
end
