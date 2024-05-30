require "rails_helper"

RSpec.describe(OpenWeatherMap::Clients::Weather) do
  describe "#currnet_weather" do
    subject(:current_weather) { described_class.new(app_id:).current_weather(lat: 51.5073219, lon: -0.1276474, units:, mode:, lang:) }

    let(:units) { 'standard' }
    let(:mode) { 'json' }
    let(:lang) { 'en' }

    let(:cache_key) { { lat: 51.5073219, lon: -0.1276474, units:, mode:, lang:} }

    context "with invalid api id" do
      let(:app_id) { "foo" }
      let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/401.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=foo&lang=en&lat=51.5073219&lon=-0.1276474&mode=json&units=standard")
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
        expect(current_weather).to(eq([401, stubbed_response]))
        expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(false))
      end
    end

    context "with valid api id" do
      let(:app_id) { "bar" }
      let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.json") }
      let(:expected_result) { JSON.parse(stubbed_response) }

      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=en&lat=51.5073219&lon=-0.1276474&mode=json&units=standard")
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
        expect(current_weather).to(eq([200, stubbed_response]))
        expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(true))
      end

      context "when units, mode, lang are not in allowed list" do
        let(:units) { nil }
        let(:mode) { nil }
        let(:lang) { nil }

        let(:cache_key) { { lat: 51.5073219, lon: -0.1276474, units: 'standard', mode: 'json', lang: 'en' } }

        it "defaults units to standard, mode to json and lang to en" do
          expect(OpenWeatherMap::Clients::Caching).to receive(:fetch).with(cache_key, namespace: :openweathermap_current_weather).and_return(true)

          current_weather
        end
      end

      context "when mode is xml" do
        let(:mode) { 'xml' }
        let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.xml") }

        before do
          stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=en&lat=51.5073219&lon=-0.1276474&mode=xml&units=standard")
            .with(
              headers: {
                "Accept" => "*/*",
                "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                "User-Agent" => "Ruby",
              },
            )
                .to_return(body: stubbed_response, status: 200)
        end

        it "returns 200 xml response and cashes it" do
          expect(current_weather).to(eq([200, stubbed_response]))
          expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(true))
        end
      end

      context "when mode is html" do
        let(:mode) { 'html' }
        let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200.html") }

        before do
          stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=en&lat=51.5073219&lon=-0.1276474&mode=html&units=standard")
            .with(
              headers: {
                "Accept" => "*/*",
                "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                "User-Agent" => "Ruby",
              },
            )
                .to_return(body: stubbed_response, status: 200)
        end

        it "returns 200 html response and cashes it" do
          expect(current_weather).to(eq([200, stubbed_response]))
          expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(true))
        end
      end

      context "when units is metric" do
        let(:units) { 'metric' }
        let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200_metric.json") }

        before do
          stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=en&lat=51.5073219&lon=-0.1276474&mode=json&units=metric")
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
          expect(current_weather).to(eq([200, stubbed_response]))
          expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(true))
        end
      end

      context "when units is imperial" do
        let(:units) { 'imperial' }
        let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200_imperial.json") }

        before do
          stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=en&lat=51.5073219&lon=-0.1276474&mode=json&units=imperial")
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
          expect(current_weather).to(eq([200, stubbed_response]))
          expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(true))
        end
      end

      context "when lang is es" do
        let(:lang) { 'es' }
        let(:stubbed_response) { File.read("spec/services/open_weather_map/clients/examples/weather/200_es.json") }

        before do
          stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=bar&lang=es&lat=51.5073219&lon=-0.1276474&mode=json&units=standard")
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
          expect(current_weather).to(eq([200, stubbed_response]))
          expect(Rails.cache.exist?(cache_key, namespace: :openweathermap_current_weather)).to(be(true))
        end
      end
    end
  end
end
