module OpenWeatherMap
  module Clients
    class Caching < Caching::BaseCaching
      EXPIRES_IN = 10.minutes
    end
  end
end
