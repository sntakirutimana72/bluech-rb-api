module Users
  class RegistrationsController < Devise::RegistrationsController
    include Responsible

    protected

    def sign_up(_, resource)
      # Prevent Devise from attempting to write to session store since it is disabled on API.
      super(resource, store: false)
    end

    def respond_with(res, _ = {})
      return as_unprocessable(error: format_resource_errors(res)) unless res.persisted?

      as_created(user: UserSerializer.new(res), message: 'Signed up successfully.')
    end
  end
end
