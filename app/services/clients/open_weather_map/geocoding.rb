# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    class Geocoding < BaseClient
      base_uri "https://api.openweathermap.org/geo/1.0"

      def direct(q:, limit: 1)
        query = {
          q: q,
          limit: limit,
          appid: @api_id,
        }

        get("/direct", query:)
      end

      # TODO: Implement zip geocoding
      # TODO: Implement reverse geocoding
    end
  end
end
