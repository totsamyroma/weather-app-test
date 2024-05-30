require "rails_helper"

RSpec.describe(Clients::OpenWeatherMap::Geocoding) do
  describe "#direct" do
    subject(:geocoding) { described_class.new(app_id).direct(q: "London") }

    context "with invalid api id" do
      let(:app_id) { "foo" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/geocoding/401.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/geo/1.0/direct?appid=foo&limit=1&q=London")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Ruby",
            },
          )
          .to_return(body: stubbed_response, status: 401)
      end

      it { is_expected.to(eq(expected_result)) }
    end

    context "with valid api id" do
      let(:app_id) { "bar" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/geocoding/200.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/geo/1.0/direct?appid=bar&limit=1&q=London")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Ruby",
            },
          )
          .to_return(body: stubbed_response, status: 200)
      end

      it { is_expected.to(eq(expected_result)) }
    end
  end
end
