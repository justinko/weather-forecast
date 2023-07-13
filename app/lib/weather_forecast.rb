class WeatherForecast
  Temperature = Data.define(:date, :max, :min)

  attr_reader :days

  def initialize(postal_code:, latitude:, longitude:, days:)
    @postal_code = postal_code
    @latitude = latitude
    @longitude = longitude
    @days = days
  end

  def current_temperature
    response.json.dig("current_weather", "temperature")
  end

  def temperatures
    days.to_i.times.with_object([]) do |index, temps|
      temps << Temperature.new(
        response.json.dig("daily", "time")[index],
        response.json.dig("daily", "temperature_2m_max")[index],
        response.json.dig("daily", "temperature_2m_min")[index]
      )
    end
  end

  private

  def response
    @response ||= HTTPX.get("https://api.open-meteo.com/v1/forecast",
      params: {
        latitude: @latitude,
        longitude: @longitude,
        forecast_days: days,
        current_weather: true,
        temperature_unit: "fahrenheit",
        daily: "temperature_2m_max,temperature_2m_min",
        timezone: "auto"
      }
    )
  end
end
