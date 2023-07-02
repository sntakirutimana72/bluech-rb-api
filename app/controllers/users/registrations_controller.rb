module Users
  class RegistrationsController < Devise::RegistrationsController
    include Responsible

    protected

    def sign_up(_, resource)
      # Prevent Devise from attempting to write to session store since it is disabled on API.
      super(resource, store: false)
    end

    def respond_with(resource, _ = {})
      if resource.persisted?
        as_created(
          user: UserSerializer.new(resource), message: 'Signed up successfully.'
        )
      else
        as_unprocessable(
          error: format_resource_errors(resource)
        )
      end
    end
  end
end
