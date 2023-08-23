module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include Authenticable::DeviseJWTStrategy

    identified_by :current_user

    def connect
      self.current_user = verify_authenticity
    end

    def disconnect
      self.current_user = nil
    end
  end
end
