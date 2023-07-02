class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Responsible

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
  end

  def format_resource_errors(resource)
    resource.errors.full_messages.join('\n\n')
  end
end
