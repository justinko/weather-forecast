require "application_system_test_case"

class WeatherForecastTest < ApplicationSystemTestCase
  test "no results found for a given address" do
    stub_request(
      :get, "https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=zzzzzzzzzzzzzzzzzzzzzzzz"
    ).to_return(status: 200, body: JSON([]))

    visit root_path
    fill_in "Address", with: "zzzzzzzzzzzzzzzzzzzzzzzz"
    click_on "Forecast"
    assert_text "No results found for the given address"
  end

  test "results found and cached for a given address" do
    stub_request(
      :get, "https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=4337%20e%20maplewood%20way"
    ).to_return(
      status: 200,
      body: JSON(
        [
          {
            "lat" => "39.604422950216346",
            "lon" => "-104.93627128224671",
            "display_name" => "4337, East Maplewood Way, Centennial, Arapahoe County, Colorado, 80121, United States",
            "address" => {
              "postcode" => "80121"
            }
          }
        ]
      )
    )
    stub_request(
      :get, "https://api.open-meteo.com/v1/forecast?current_weather=true&daily=temperature_2m_max,temperature_2m_min&forecast_days=3&latitude=39.604422950216346&longitude=-104.93627128224671&temperature_unit=fahrenheit&timezone=auto"
    ).to_return(
      status: 200,
      body: JSON(
        {
          "current_weather" => {
            "temperature" => 82.1,
          },
          "daily" => {
            "time" => ["2023-07-13","2023-07-14","2023-07-15"],
            "temperature_2m_max" => [93.1,86.8,85.7],
            "temperature_2m_min" => [64.7,64.0,62.6]
          }
        }
      ),
      headers: {
        "Content-Type" => "application/json"
      }
    )

    visit root_path
    fill_in "Address", with: "4337 e maplewood way"
    fill_in "Days", with: "3"
    click_on "Forecast"
    assert_text "4337, East Maplewood Way, Centennial, Arapahoe County, Colorado, 80121, United States"
    assert_text "is 82.1"
    assert_text "next 3 days"
    assert_text "Date: 2023-07-13"
    assert_text "Maximum temperature: 93.1"
    assert_text "Minimum temperature: 64.7"
    assert_no_text "cached response"
    refresh
    assert_text "cached response for postal code 80121"
  end
end
