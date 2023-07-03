module CommonTestHelpers
  module Parsers
    def load_body(fixture_type)
      @body = digest(fixture_type)
    end

    private

    def digest(type)
      case type
      when :request
        JSON.parse(response.body)
      when :feature
        JSON.parse(page.source)
      else
        ''
      end
    end
  end

  module HttpParams
    include ActiveRecordTestHelpers

    def msg_params(options = {})
      { message: FactoryMessage.any_options(options) }
    end

    def user_params(options = {})
      { user: FactoryUser.any_options(options) }
    end

    def auth_params(user)
      {
        user: {
          email: user.is_a?(Hash) ? user[:email] : user.email,
          password: user.is_a?(Hash) ? user[:password] : user.password
        }
      }
    end
  end
end
