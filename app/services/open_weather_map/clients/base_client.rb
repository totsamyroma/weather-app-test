# frozen_string_literal: true

module OpenWeatherMap
  module Clients
    class BaseClient
      include HTTParty
      debug_output $stdout if Rails.env.development?

      def initialize(app_id: nil)
        @app_id = app_id || ENV["OPEN_WEATHER_MAP_APP_ID"]
      end

      def get(path, query:)
        self.class.get(path, query:)
      end
    end
  end
end
