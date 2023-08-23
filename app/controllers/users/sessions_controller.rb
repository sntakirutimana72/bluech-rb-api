module Users
  class SessionsController < Devise::SessionsController
    include Responsible

    private

    def respond_with(resource, _ = {})
      as_success(user: UserSerializer.new(resource), message: 'Signed in successfully.')
    end

    def respond_to_on_destroy
      return as_success(message: 'Logged out successfully.') if current_user

      as_unauthorized(error: 'Could not find an active session.')
    end
  end
end
