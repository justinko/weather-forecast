Rails.application.routes.draw do
  resource :weather_forecast, only: [:new, :show]
  root "weather_forecasts#new"
end
