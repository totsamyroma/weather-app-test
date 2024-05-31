require 'rails_helper'

RSpec.describe "Api::V1::Weather", type: :request do
  describe "GET /api/v1/weather/city" do
    context "with json format" do
      subject(:city_weather) { get "/api/v1/weather/city", params: params }

      let(:params) { { city: "London", mode: "json" } }

      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [200, stubbed_weather_response]) }
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.json") }

      it "returns http success" do
        expect(OpenWeatherMap::Clients::Geocoding).to receive(:new).and_return(geocoding_client)
        expect(OpenWeatherMap::Clients::Weather).to receive(:new).and_return(weather_client)

        city_weather
        expect(response).to have_http_status(:success)
        expect(CGI.unescapeHTML(response.body)).to eq(stubbed_weather_response)
      end
    end

    context "with xml format" do
      subject(:city_weather) { get "/api/v1/weather/city", params: params }

      let(:params) { { city: "London", mode: "xml" } }

      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [200, stubbed_weather_response]) }
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.xml") }

      it "returns http success" do
        expect(OpenWeatherMap::Clients::Geocoding).to receive(:new).and_return(geocoding_client)
        expect(OpenWeatherMap::Clients::Weather).to receive(:new).and_return(weather_client)

        city_weather
        expect(response).to have_http_status(:success)
        expect(CGI.unescapeHTML(response.body)).to eq(stubbed_weather_response)
      end
    end

    context "with html format" do
      subject(:city_weather) { get "/api/v1/weather/city", params: params }

      let(:params) { { city: "London", mode: "xml" } }

      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [200, stubbed_weather_response]) }
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.html") }

      it "returns http success" do
        expect(OpenWeatherMap::Clients::Geocoding).to receive(:new).and_return(geocoding_client)
        expect(OpenWeatherMap::Clients::Weather).to receive(:new).and_return(weather_client)

        city_weather
        expect(response).to have_http_status(:success)
        expect(CGI.unescapeHTML(response.body)).to eq(stubbed_weather_response)
      end
    end

    context "with invalid token" do
      subject(:city_weather) { get "/api/v1/weather/city", params: params }

      let(:params) { { city: "London" } }

      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [401, stubbed_geocoding_response]) }
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/401.json") }

      it "returns unauthorized error" do
        expect(OpenWeatherMap::Clients::Geocoding).to receive(:new).and_return(geocoding_client)

        city_weather
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({ error: "Can't access OpenWeatherMap API" }.to_json)
      end
    end

    context "with blank city name" do
      subject(:city_weather) { get "/api/v1/weather/city", params: params }

      let(:params) { { city: "" } }

      let(:geocoding_client) { nil }
      let(:weather_client) { nil }

      it "returns bad request error" do
        city_weather
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({ error: "City name can't be blank" }.to_json)
      end
    end

    context "when can't fetch weather" do
      subject(:city_weather) { get "/api/v1/weather/city", params: params }

      let(:params) { { city: "Foo" } }

      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/400.json") }
      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [400, stubbed_weather_response]) }

      it "returns not found error" do
        expect(OpenWeatherMap::Clients::Geocoding).to receive(:new).and_return(geocoding_client)
        expect(OpenWeatherMap::Clients::Weather).to receive(:new).and_return(weather_client)

        city_weather
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({ error: "Can't get weather information" }.to_json)
      end
    end
  end
end
