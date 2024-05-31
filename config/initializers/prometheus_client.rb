require "prometheus/client"

prometheus = Prometheus::Client.registry

# Counter
module Metrics
  class ReadLatency
    # creates two metrics:
    # api_v1_weather_city_requests_sum - response time summary
    # api_v1_weather_city_requests_count - number or requests
    METRIC = Prometheus::Client::Summary.new(:api_v1_weather_city_requests, docstring: "A summary of the HTTP request duration in seconds")

    def self.observe(&block)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield if block_given?

      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      duration = end_time - start_time
      METRIC.observe(duration)
    end

    # TODO: add following metrics:
    #
    # in order to investigate if we'll ever hit free plan limit and estimate potential costs
    # - OpenweatherMap API requests number
    # - OpenweatherMap API requests rate
    #
    # in order to decide if we should cache unsuccessfull requests
    # right now any unsuccessfull request is not cached
    # meaning /weather/city?city=FooBarBaz will always hit OpenWeatherMap API
    # resulting waste of requests capacity
    # - Number of failed requests, aka City not found.
    #
    # miscellanous Metrics
    # - Number of requests per city
    # - Number of requests per mode (json, xml, html)
    # - Number of requests per units (standard, metric, imperial)
    # - Number of requests per language
  end
end

# Register Metrics
prometheus.register(Metrics::ReadLatency::METRIC)
