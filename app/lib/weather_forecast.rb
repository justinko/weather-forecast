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
    json.dig("current_weather", "temperature")
  end

  def temperatures
    days.to_i.times.with_object([]) do |index, temps|
      temps << Temperature.new(
        json.dig("daily", "time")[index],
        json.dig("daily", "temperature_2m_max")[index],
        json.dig("daily", "temperature_2m_min")[index]
      )
    end
  end

  def cached?
    !!@cached
  end

  private

  def json
    @json ||= begin
      if Rails.cache.exist?(@postal_code)
        @cached = true && Rails.cache.read(@postal_code)
      else
        Rails.cache.write(@postal_code, response.json, expires_in: 30.minutes)
        response.json
      end
    end
  end

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
