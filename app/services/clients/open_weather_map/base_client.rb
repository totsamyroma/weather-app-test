# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    class BaseClient < Clients::BaseClient
      def initialize(api_id = ENV["OPEN_WEATHER_MAP_API_ID"])
        @api_id = api_id
      end
    end
  end
end
