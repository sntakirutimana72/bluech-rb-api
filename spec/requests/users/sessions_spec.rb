require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  after(:context) do
    purge_all_records
  end

  context '/users/login' do
    it 'when no user account' do
      post(
        user_session_path,
        params: auth_params(ActiveRecordTestHelpers::FactoryUser.any_options)
      )
      expect(response).to have_http_status(:unauthorized)
    end

    it 'when wrong password' do
      user = ActiveRecordTestHelpers::FactoryUser.any
      user.password = nil
      post(user_session_path, params: auth_params(user))
      expect(response).to have_http_status(:unauthorized)
    end

    it 'Signed in successfully' do
      user = ActiveRecordTestHelpers::FactoryUser.any(email: 'wow_user@email.test')
      post(user_session_path, params: auth_params(user))
      expect(response).to have_http_status(:ok)
    end
  end

  context '/users/logout' do
    let(:logout) do
      lambda { |status|
        delete(destroy_user_session_path, headers: @headers)
        expect(response).to have_http_status(status)
      }
    end

    before(:context) do
      @user = ActiveRecordTestHelpers::FactoryUser.any
    end

    it 'when no active session' do
      delete(destroy_user_session_path)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'logged out successfully' do
      authorize(@user)
      logout.call(:success)
    end

    it 'when logging out twice' do
      authorize(@user)
      logout.call(:success)
      logout.call(:unauthorized)
    end
  end
end
