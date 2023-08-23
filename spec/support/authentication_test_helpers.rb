require 'devise/jwt/test_helpers'

module AuthenticationTestHelpers
  module DeviseJWTStrategy
    protected

    def allowed_headers(headers: {})
      {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        **headers
      }
    end

    def authorize(user = nil, headers: {})
      @current_user = user.nil? ? ActiveRecordTestHelpers::FactoryUser.any : user
      @headers = Devise::JWT::TestHelpers.auth_headers(allowed_headers(headers:), @current_user)
    end

    def fake_authorize(headers: {})
      @headers = allowed_headers(
        headers: {
          **headers,
          Authorization: 'FAKE-X-TOKEN'
        }
      )
    end
  end
end
