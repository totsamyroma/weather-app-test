class Rack::Attack
  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/v1/weather/city")
  end
end
