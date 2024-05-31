# Simple Weather API
## Brief
This is a simple Ruby on Rails application that exposes an API for retrieving weather data for a given city.  
The API endpoint allows users to retrieve weather data such as temperature, humidity, and wind speed for a specific city.  

## Installation
### Requirements:  
Make sure you have Docker installed on your machine.   
Docker will take care of eveyrthing else.

### Configuration
For correct work of the application, you need to set OpenWeatherMap API key under `OPEN_WEATHER_MAP_APP_ID` environment variable.
Copy example `.env` file and set your API key.
```shell
$ cp .env.example .env
```
```yaml
# in .env file
OPEN_WEATHER_MAP_APP_ID=your_open_weather_map_api_key
```
> NOTE:  
> If you don't have a key, you can get it by registering on [OpenWeatherMap](https://home.openweathermap.org/users/sign_up) website.  
> API key could be obtained from [API keys](https://home.openweathermap.org/api_keys) section.  
> Free key limitations is 60 calls per minute and 1,000,000 calls per month.

### Build application
```shell
$ docker-compose build
```
## Usage
### Run application: attached mode
```shell
$ docker-compose up
```
> NOTE:  
> This mode show logs from all docker-compose services what might be not very useful.  
> Applications stops automatically by pressing `Ctrl+C`

### Build and Run application 
```shell
$ docker-compose up -d --build
```

### Run application: detached mode (recommended)
```shell
$ docker-compose up -d
```

### Stop application: detached mode
```shell
$ docker-compose down
```

### Check servie logs: attached mode (recommended)
```shell
$ docker-compose logs -f web
``` 
> NOTE:  
> This mode attaches to logs of service and will show logs in real-time.  
> To check logs of other services replace `web` with service name.  
> Availablle services: `web`, `postgres`, `redis`, `otel-collector`, `jaeger`, `prometheus`, `grafana`

### Open Rails console in running container
```shell
$ docker-compose exec web bin/rails c
```

## Tests
> Note:
> You might need to run migrations before running tests.
> To run migrations, open Rails console in running container and run:
 ```shell
 $ RAILS_ENV=test bin/rails db:migrate
 ```
### Run tests
```shell
$ rspec
```

 ## Rubocop
 ### Common use
 ```shell
 $ rubocop
 ```
 ### Rubocop with auto-correct
 ```shell
 $ rubocop -a
 ```
 or for specific cop
 ```shell
 $ rubocop -a --only <cop_name>
 ```
Offences to be ignored could be set in `.rubocop_todo.yml` file.
```shell
$ rubocop --regenerate-todo
```

## Dev Notes
### OpenWeatherMap API
API flow is displayed in the [diagram ](https://miro.com/app/board/uXjVKBDsnIQ=/?share_link_id=652270012803)

OpenWeatherMap deprecates automatic geolocation for Weather API.
This splits flow into two parts:
- Get city coordinates by city name from OpenWeatherMap Geolocating API `OpenWeatherMap::Clients::Geocoding.new.direct(...)`
- Get weather data by coordinates from OpenWeatherMap Weather API `OpenWeatherMap::Clients::Weather.current_wather(...)`

In order to reduce external API usage and avoid rate limit hits, both clients user cache.  
Geolocation cache does not expiry date because unlikely city coordinates will change.  
Weather cache is set to 10 minutes by default. This is a reasonable time for weather data.

Both clients are wrapped in `OpenWeatherMap::Weather` service that provides a single entry point for weather data retrieval.T
The service also uses caching.

### Caching logic
OpenWeatherMap API has default modes and units for weather data.  
This was used in cache key generation, because:
```shell
GET /weather?q=London
```
is effectively the same as
```shell
GET /weather?q=London&units=standard&mode=json&lang=en
```
Client uses default units and mode for weather data, so it is safe to use them in cache key generation and avoids unnecessary cache hits for equivalent requests.

It was decided not to add cache APP Id, because in future we could implement token load balancing.  
Having APP Id will make unnecessary cache overhead for equivalent requests.

Example:
```Ruby
module OpenWeatherMap
  module Clients
    class Weather < BaseClient
      ...

      def current_weather(lat:, lon:, units: nil, mode: nil, lang: nil)
        units = DEFAULT_UNITS unless units.in? ALLOWED_UNITS
        mode = DEFAULT_MODE unless mode.in? ALLOWED_MODES
        lang = DEFAULT_LANG unless lang.in? ALLOWED_LANGS

        query = { lat: lat, lon: lon, units: units, mode: mode, lang: lang, appid: @app_id }

        cache_key = query.except(:appid)

        Caching.fetch(cache_key, namespace: CACHE_NAMESPACE) do
           ...
        end
      end

      ...
    end
  end
end
```

## Utilites
### Grafana UI
Open browser and navigate to `http://localhost:3001`
> NOTE: Credentials requeried  
> username: `admin`  
> password: `admin`

> NOTE: Dashboards  
> Three dashboards are available:  
> - Averagge Rate Dashboard  
> - Average Response Time Dashboard  
> - Home Dashboard (both Average Rate and Average Response Time in one)
>  For more details go to `Explore` 

> NOTE: Data Sources  
> `Jaeger` and `Prometheus` are used as data sources at the moment.  
> For more details go to `Explore` and select required data source.

### Prometheus UI
Open browser and navigate to `http://localhost:9090`

### Jaeger UI
Open browser and navigate to `http://localhost:16686`
> NOTE: Traces  
> Make few api calls to see traces in Jaeger UI.  
> To see traces, click on `Search` and then select `weather_api` under `Servce` dropdown.  
> Traces are bieing generated for each API call with Opentelemetry.

### Postman
Postman collection is available in `doc/postman/Simple Weather API.postman_collection.json` file.  
Collection contains API documentations and examples of requests.  
Import it to Postman and use for testing API.

## Future Improvements
### Functionality
-[ ] Add support for geolocation by ZIP and country codes  
-[ ] Add support for multiple languages  
-[ ] Expand language support  
-[ ] Add token based authentication  
-[ ] Reduce weather cachce life to a possible minimum  
-[ ] Store freueqent citi names or coordinates in database. Such information could be regulary refreshed with background job to response time.
-[ ] Reduce Rack::Attack throttling time to a possible minimum
### Metrcis
-[ ] Add visualisation for CPU usage in Grafana  
-[ ] Add visualisation for RAM usage in Grafana  
-[ ] Add metrics for failed requests  
-[ ] Add metrics for OpenWeatherMap API rate exceedings   