class AccountsController < ApplicationController
  def profile
    as_success(user: UserSerializer.new(current_user))
  end
end
