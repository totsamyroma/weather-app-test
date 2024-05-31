module Weather
  module Errors
    class InvalidTokenError < StandardError; end
    class CityNotFoundError < StandardError; end
    class WeatherFetchError < StandardError; end
  end
end
