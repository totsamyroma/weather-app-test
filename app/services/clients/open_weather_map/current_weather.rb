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
          units: units,
          lang: lang,
          appid: @api_id,
        }

        get("/weather", query:)
      end
    end
  end
end
