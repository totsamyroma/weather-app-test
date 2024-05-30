# app/services/clients/open_weather_map/geocoding.rb

module OpenWeatherMap
  module Clients
    class Geocoding < BaseClient
      base_uri "https://api.openweathermap.org/geo/1.0"

      ALLOWED_LIMIT = (1..5)

      CACHE_NAMESPACE = :openweathermap_geocoding

      DEFAULT_LIMIT = 1

      def direct(q:, limit: nil)
        limit = DEFAULT_LIMIT unless limit.in?(ALLOWED_LIMIT)

        query = { q: q.upcase, limit: limit, appid: @app_id }

        cache_key = query.except(:appid)

        Caching.fetch(cache_key, namespace: CACHE_NAMESPACE, expires_in: nil) do
          response = get("/direct", query:)

          break [response.code, response.body] unless response.success?

          [response.code, response.body]
        end
      end

      private

      def cache_params
        { namespace: CACHE_NAMESPACE }
      end
    end
  end
end
