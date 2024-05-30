# app/services/weather/caching.rb

module Caching
  class BaseCaching
    EXPIRES_IN = 1.hour

    def self.fetch(key, namespace:, expires_in: nil, &block)
      expires_in ||= EXPIRES_IN

      Rails.cache.fetch(key, namespace: namespace, expires_in: expires_in, &block)
    end
  end
end
