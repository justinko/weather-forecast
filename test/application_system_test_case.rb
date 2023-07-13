require "test_helper"
require "webmock/minitest"
require "httpx/adapters/webmock"
WebMock.enable!
WebMock.disable_net_connect!(
  net_http_connect_on_start: true,
  allow_localhost: true,
  allow: Webdrivers::Common.subclasses.map { Regexp.new(_1.base_url) }
)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
