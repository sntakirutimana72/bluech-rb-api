module Users
  class AccountsController < ApplicationController
    def profile
      as_success(user: ProfileSerializer.new(current_user))
    end

    def signed_user
      as_success(user: UserSerializer.new(current_user))
    end

    def refresh_session
      head :ok
    end
  end
end
