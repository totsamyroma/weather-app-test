require "rails_helper"

RSpec.describe(OpenWeatherMap::Clients::Geocoding) do
  describe "#direct" do
    subject(:geocoding) { described_class.new(app_id:).direct(q: city_name, limit: 1) }

    let(:city_name) { "London" }
    let(:cache_key) { { q: city_name.upcase, limit: 1 } }

    context "with invalid api id" do
      let(:app_id) { "foo" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/geocoding/401.json") }

      before do
        stub_request(:get, "https://api.openweathermap.org/geo/1.0/direct?appid=foo&limit=1&q=#{city_name.upcase}")
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
        expect(geocoding).to(eq([401, stubbed_response]))
        expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_geocoding)).to(be(false))
      end
    end

    context "with valid api id" do
      let(:app_id) { "bar" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/geocoding/200.json") }

      before do
        stub_request(:get, "https://api.openweathermap.org/geo/1.0/direct?appid=bar&limit=1&q=LONDON")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Ruby",
            },
          )
          .to_return(body: stubbed_response, status: 200)
      end

      it "returns 200 response and caches it" do
        expect(geocoding).to(eq([200, stubbed_response]))
        expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_geocoding)).to(be(true))
      end
    end
  end
end
