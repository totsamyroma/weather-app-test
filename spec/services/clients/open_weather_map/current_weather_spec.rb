require "rails_helper"

RSpec.describe(Clients::OpenWeatherMap::CurrentWeather) do
  describe "#weather" do
    subject(:geocoding) { described_class.new(app_id).weather(lat: 51.5073219, lon: -0.1276474) }

    context "with invalid api id" do
      let(:app_id) { "foo" }
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/weather/401.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=foo&lang=&lat=51.5073219&lon=-0.1276474&units=")
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
      let(:stubbed_response) { File.read("spec/services/clients/open_weather_map/examples/weather/200.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=&lat=51.5073219&lon=-0.1276474&units=")
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
