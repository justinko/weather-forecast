class WeatherForecastsController < ApplicationController
  def new
  end

  def show
    geocoder = Geocoder.search(params.require(:address))

    if geocoder.any?
      @weather_forecast = WeatherForecast.new(
        postal_code: geocoder.first.postal_code,
        latitude: geocoder.first.latitude,
        longitude: geocoder.first.longitude,
        days: params.require(:days)
      )
    else
      flash.now.alert = "No results found for the given address"
      render :new, status: :unprocessable_entity
    end
  end
end
