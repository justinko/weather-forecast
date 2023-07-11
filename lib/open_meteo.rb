module OpenMeteo
  class Error < StandardError; end

  def self.current_temperature(latitude:, longitude:)
    json = HTTPX.get("https://api.open-meteo.com/v1/forecast",
      params: {latitude:, longitude:, current_weather: true}
    ).json

    if json["error"]
      raise Error, json["reason"]
    else
      json["current_weather"]["temperature"]
    end
  end
end
