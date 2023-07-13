class WeatherForecastsController < ApplicationController
  def new
  end

  def show
    @geocode = Geocoder.search(params.require(:address)).first

    if @geocode
      @weather_forecast = WeatherForecast.new(
        postal_code: @geocode.postal_code,
        latitude: @geocode.latitude,
        longitude: @geocode.longitude,
        days: params.require(:days).to_i
      )
    else
      flash.now.alert = "No results found for the given address"
      render :new, status: :unprocessable_entity
    end
  end
end
