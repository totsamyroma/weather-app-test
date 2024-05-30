# frozen_string_literal: true

module Clients
  module OpenWeatherMap
    class BaseClient < Clients::BaseClient
      def initialize(app_id = ENV["OPEN_WEATHER_MAP_APP_ID"])
        @app_id = app_id
      end
    end
  end
end
