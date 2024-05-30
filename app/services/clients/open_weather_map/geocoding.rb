# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    class Geocoding < BaseClient
      base_uri "https://api.openweathermap.org/geo/1.0"

      def direct(q:, limit: 1)
        # TODO: validate query

        query = {
          q: q.upcase,
          limit: limit,
          appid: @app_id,
        }

        Rails.cache.fetch({ api: :geocoding, action: :direct, **query.except(:appid) }, namespace: :openweathermap) do
          code, _body = result = get("/direct", query:)

          break result unless code == 200

          result
        end
      end

      # TODO: Implement zip geocoding
      # TODO: Implement reverse geocoding
    end
  end
end
