module Users
  class RegistrationsController < Devise::RegistrationsController
    include Responsible

    protected

    def sign_up(_, resource)
      # Prevent Devise from attempting to write to session store since it is disabled on API.
      super(resource, store: false)
    end

    def respond_with(resource, _ = {})
      return as_created(
        user: UserSerializer.new(resource), message: 'Signed up successfully.'
      ) if resource.persisted?

      as_unprocessable(
        message: "User couldn't be created successfully.", error: resource.errors
      )
    end
  end
end
