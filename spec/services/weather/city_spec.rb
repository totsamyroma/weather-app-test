require "rails_helper"

RSpec.describe(Weather::City) do
  describe "#current_weather" do
    subject(:current_weather) { described_class.new(city:, units:, mode:, lang:, geocoding_client:, weather_client:).current_weather }

    let(:city) { "London" }
    let(:units) { "standard" }
    let(:mode) { "json" }
    let(:lang) { "en" }

    let(:cache_key) { { city: city.upcase, units: "standard", mode: "json", lang: "en" } }

    context "with valid city" do
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.json") }
      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [200, stubbed_weather_response]) }
      let(:expected_result) { stubbed_weather_response }

      it "returns 200 response and cashes it" do
        expect(current_weather).to eq(expected_result)
        expect(Rails.cache.exist?(cache_key, namespace: :weather_city_current_weather)).to(be(true))
      end
    end

    context "with invalid geo token" do
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/401.json") }
      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [401, stubbed_geocoding_response]) }
      let(:weather_client) { nil }
      let(:expected_result) { [Weather::Errors::InvalidTokenError, "Can't access OpenWeatherMap API"] }

      it "raises error and does not cache it" do
        expect { current_weather }.to raise_error(*expected_result)
        expect(Rails.cache.exist?(cache_key, namespace: :weather_city_current_weather)).to(be(false))
      end
    end

    context "with blank city name" do
      let(:city) { "" }

      let(:geocoding_client) { nil }
      let(:weather_client) { nil }
      let(:expected_result) { [Weather::Errors::WeatherFetchError, "City name can't be blank"] }

      it "raises error and does not cache it" do
        expect { current_weather }.to raise_error(*expected_result)
        expect(Rails.cache.exist?(cache_key, namespace: :weather_city_current_weather)).to(be(false))
      end
    end

    context "with invalid city name" do
      let(:city) { "XXX" }

      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, [].to_json]) }
      let(:weather_client) { nil }
      let(:expected_result) { [Weather::Errors::CityNotFoundError, "Can't locate the city"] }

      it "raises error and does not cache it" do
        expect { current_weather }.to raise_error(*expected_result)
        expect(Rails.cache.exist?(cache_key, namespace: :weather_city_current_weather)).to(be(false))
      end
    end

    context "with invalid weather token" do
      let(:city) { "London" }

      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/401.json") }
      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [401, stubbed_weather_response]) }
      let(:expected_result) { [Weather::Errors::InvalidTokenError, "Can't access OpenWeatherMap API"] }

      it "raises error and does not cache it" do
        expect { current_weather }.to raise_error(*expected_result)
        expect(Rails.cache.exist?(cache_key, namespace: :weather_city_current_weather)).to(be(false))
      end
    end

    context "when invalid coorditates" do
      let(:stubbed_geocoding_response) { File.read("spec/services/open_weather_map/clients/examples/geocoding/200.json") }
      let(:stubbed_weather_response) { File.read("spec/services/open_weather_map/clients/examples/weather/400.json") }
      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding, direct: [200, stubbed_geocoding_response]) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather, current_weather: [400, stubbed_weather_response]) }
      let(:expected_result) { [Weather::Errors::WeatherFetchError, "Can't get weather information"] }

      it "raises error and does not cache it" do
        expect { current_weather }.to raise_error(*expected_result)
        expect(Rails.cache.exist?(cache_key, namespace: :weather_city_current_weather)).to(be(false))
      end
    end

    context "when units, mode, lang are not in allowed list" do
      let(:units) { nil }
      let(:mode) { nil }
      let(:lang) { nil }

      let(:cache_key) { { city: 'LONDON', units: 'standard', mode: 'json', lang: 'en' } }

      let(:geocoding_client) { instance_double(OpenWeatherMap::Clients::Geocoding) }
      let(:weather_client) { instance_double(OpenWeatherMap::Clients::Weather) }

      it "defaults units to standard, mode to json and lang to en" do
        expect(Weather::Caching).to receive(:fetch).with(cache_key, namespace: :weather_city_current_weather).and_return(true)

        current_weather
      end
    end
  end
end
