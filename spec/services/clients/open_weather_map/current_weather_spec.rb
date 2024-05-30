require "rails_helper"

RSpec.describe(Clients::OpenWeatherMap::CurrentWeather) do
  describe "#weather" do
    subject(:current_weather) { described_class.new(app_id).weather(lat: 51.5073219, lon: -0.1276474) }

    let(:cache_key) { { api: :weather, action: :weather, lat: 51.5073219, lon: -0.1276474, units: nil, mode: nil, lang: nil } }

    context "with invalid api id" do
      let(:app_id) { "foo" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/weather/401.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=foo&lang=&lat=51.5073219&lon=-0.1276474&mode=&units=")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Ruby",
            },
          )
          .to_return(body: stubbed_response, status: 401)
      end

      it "returns 401 response and does not cache it" do
        expect(current_weather).to(eq([401, expected_result]))
        expect(Rails.cache.exist?(cache_key, namespace: :openweathermap)).to(be(false))
      end
    end

    context "with valid api id" do
      let(:app_id) { "bar" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/weather/200.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=&lat=51.5073219&lon=-0.1276474&mode=&units=")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Ruby",
            },
          )
          .to_return(body: stubbed_response, status: 200)
      end

      it "returns 200 response and cashes it" do
        expect(current_weather).to(eq([200, expected_result]))
        expect(Rails.cache.exist?(cache_key, namespace: :openweathermap)).to(be(true))
      end
    end
  end
end
