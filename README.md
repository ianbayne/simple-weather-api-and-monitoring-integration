# Simple Weather API and Monitoring Integration

## Overview

This is a simple [Ruby on Rails](https://rubyonrails.org/) app with an endpoint that retrieves weather data for a given city from [OpenWeather](https://openweathermap.org/), a public weather API. Additionally, it includes in-code monitoring through the use of [OpenTelemetry](https://opentelemetry.io/) in order to report data requests per minute and average response times. Note that the storing, processing, analyzing, and visualizing of this telemetry data will require a backend. See [Running the app locally](#Running-the-app-locally) below for further information.

## API

The API endpoint is

```
/api/v1/weather/:city
```

and returns temperature, humidity, and wind speed data in the following format upon a successful request:

```
{
  "temperature": Float,
  "humidity": Integer,
  "wind_speed": Float
}
```

It returns an error message upon an unsuccessful request. For example, when trying to fetch weather data for a non-existent city:

```
{
  "message":"Something went wrong: 404 Not Found"
}
```

### Examples of usage

Given the city of Tokyo

```
/api/v1/weather/tokyo
```

The following data is returned:

```
{
  "temperature":292.75,
  "humidity":95,
  "wind_speed":10.8
}
```

## Running the app locally

First install all the dependencies specified in the Gemfile by running `bundle install` from the top directory. Run `bin/rails server -p 3000` to start the server and then go to your browser and open http://localhost:3000/api/v1/weather/:city, substituting the name of a city for the `:city` segment key in the URL. For example, http://localhost:3000/api/v1/weather/tokyo.

### Telemetry data

You'll need to set up a backend for the gathered telemetry data. See [here](https://opentelemetry.io/ecosystem/vendors/) for a list of vendors who support OpenTelemetry.

#### Example with SigNoz

One backend option is [SigNoz](https://signoz.io/). See [this](https://signoz.io/blog/opentelemetry-ruby/) article for setup. Once you have SigNoz set up, you'll be able to run the app locally in one tab of your browser while analyzing the telemetry data in another tab. In order to do so, run the following command:

```
OTEL_EXPORTER=otlp OTEL_SERVICE_NAME=anythingYouWant OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 OTEL_RESOURCE_ATTRIBUTES=application=appName rails server
```

Once the app is running, fetch weather data for a few cities in order to generate monitoring data. Then navigate to http://localhost:3301/application, sign up for SigNoz, and click on the Traces link. From there, you'll be able to click through one of the requests on the lower right-hand of the page to view the gathered telemetry data:

<img width="800" alt="Requests per minute" src="https://github.com/ianbayne/Wishly/assets/10363087/227fd397-dc55-4ce4-a9aa-b9dae1c5b7a9">
<caption>Requests per minute</caption>
<br>
<br>
<img width="800" alt="Average response time" src="https://github.com/ianbayne/Wishly/assets/10363087/57fd5a72-e797-4f88-8100-c92b51f60dd5">
<caption>Average response time</caption>

### Running the test suite

After running `bundle install` in your terminal, run `bundle exec rspec` to run the full suite of [RSpec](http://rspec.info/) tests.

## Suggestions for improvement:
- The app is currently not very user friendly as weather data is only returned in JSON format directly in the browser and only fetchable by updating the URL. This could prove an impediment to non-technical people's use of the app and could be improved by building a frontend (which could be built using a JavaScript framework or plain HTML and/or JavaScript) that could, for example, provide an input field for users to enter the name of the city as well as nice visualizations of the returned data (similar to what we see on the [homepage](https://openweathermap.org) of OpenWeather). Going further with this idea, and thanks to OpenWeather providing location-based weather data (see the docs [here](https://openweathermap.org/api/one-call-3)), the UI could consist of a map and when the user clicks a location on the map, the latitude and longitude of that location would be sent in the API request to OpenWeather, and then the weather data for that exact location could be displayed.
- As a corollary to the above, the app in its current state has very low accessibility and could be extremely difficult for users with disabilities to make use of. Building some sort of frontend could improve accessibility.
- OpenWeather provides a `lang` parameter in order to get the output in the language of your choice. This could be made use of in order to cater to a broader range of users (i.e., non-English speakers), either through directly allowing language selection somehow or using the default from the user's browser. See the API docs [here](https://openweathermap.org/api/one-call-3#how).
- As there are quite a few cities around the world that share names (e.g., Athens, Georgia and Athens, Greece), adding some way for users to select the country or differentiate between cities with the same name would be beneficial. Some possible options include using client-side code to display a list of options when a city name is entered into an input field (OpenWeather does this on their homepage) or, having a separate field or list for countries that would update the list of available cities upon selecting a country.
- If it's judged the response from the external weather API takes too long, the external API call could be moved to a background job. This will make the request non-blocking so the app would need to immediately render a view with some sort of loading indicator until the data is available. The server could then be polled to determine when the resource is available and the UI then updated once it is available.
- The app was written in such that it will be easy to switch from OpenWeather to another weather API should that be required or desirable in the future. Simply create a new `app/services/client` with the same interface as `app/services/clients/open_weather_map.rb` and then replace the call to `open_weather_map.rb` in `app/services/get_weather_data.rb` with a call to the new client. Additionally, in the event additional weather data beyond humidity, temperature, and wind speed is required/desirable, this can also be easily implemented by updating the client to return the required data, subject to what's available from the external API. In this case, `spec/requests/api/v1/weather_spec.rb` will also need to be updated in order to take into consideration the additional weather data.
- Currently none of the weather data in the response has units (e.g., m/s for wind speed). Including these could be a possible easy win.
- While metrics and logging are not currently available for OpenTelemetry Ruby (see [here](https://opentelemetry.io/docs/languages/ruby/#status-and-releases)), once they are, adding them in could be a good way to improve maintainability and increase the speed of future bug fixes.
- The free API for OpenWeather only updates its data every < 2 hours. Given that, it may make sense to use low-level caching to cache the result of the fetch request, expiring the cache every 2 hours or so. This would reduce unnecessary fetch requests.
- From a developer experience standpoint, use of a linter and formatter like [Rubocop](https://rubocop.org/) or [Standard](https://github.com/standardrb/standard) to ensure standardization of the codebase could be invaluable in decreasing discrepancies in coding styles between developers and reducing time spent [bikeshedding](https://thedecisionlab.com/biases/bikeshedding).

