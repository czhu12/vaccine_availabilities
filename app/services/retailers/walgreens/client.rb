# frozen_string_literal: true

class Retailers::Walgreens::Client < Retailers::Base
  base_uri 'https://www.walgreens.com'
  COOKIE = File.read(File.join(__dir__, 'cookie.txt')).strip
  HEADERS = {
    'Content-Type': 'application/json',
    'User-Agent' => 'PostmanRuntime/7.29.2',
    'X-Xsrf-Token': '0/1XXCriXSO8bw==.pBUozwGaTpTcI5SkfYTDOiDKoUAccq9ywsUyYPM5158=',
    Accept: 'application/json',
    Cookie: COOKIE
  }.freeze

  def headers
    HEADERS
  end

  def post(path, params, type: '')
    with_json_response(type:) do
      self.class.post(
        path,
        body: params.to_json,
        headers:
      )
    end
  end

  def patch(path, params, type: '')
    with_json_response(type:) do
      self.class.patch(
        path,
        body: params.to_json,
        headers:
      )
    end
  end

  private

    def with_json_response(type: '')
      response = yield
      response.tap do
        unless response.success?
          message = response.dig('errors', 0, 'message') || response.dig('errors', 0, 'detail')
          raise StandardError, "#{type && "#{type} failed:"} #{message}"
        end
      end
    end
end
