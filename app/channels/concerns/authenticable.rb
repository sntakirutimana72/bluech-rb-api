module Authenticable
  module DeviseJWTStrategy
    include ActiveSupport::Concern

    private

    def verify_authenticity
      jwt_payload = JWT.decode(
        request.headers[:Authorization].split.last,
        Rails.application.credentials.fetch(:devise_jwt_secret)
      ).first
      User.find_by!(jti: jwt_payload['jti'])
    rescue StandardError
      reject_unauthorized_connection
    end
  end
end
