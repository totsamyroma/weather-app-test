# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    class CurrentWeather < BaseClient
      base_uri "https://api.openweathermap.org/data/2.5"

      # Built-in geocoding by city name/zip code has been deprecated https://openweathermap.org/current
      # Use Clients::OpenWeatherMap::Geocoding for geocoding by city name/zip code
      def weather(lat:, lon:, units: nil, mode: nil, lang: nil)
        query = {
          lat: lat,
          lon: lon,
          mode: mode,
          units: units,
          lang: lang,
          appid: @app_id,
        }

        Rails.cache.fetch({ api: :weather, action: :weather, **query.except(:appid) }, namespace: :openweathermap, expires_in: 10.minutes) do
          code, _body = result = get("/weather", query:)

          break result unless code == 200

          result
        end
      end
    end
  end
end
