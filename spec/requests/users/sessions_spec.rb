require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  after do
    purge_all_records
  end

  describe 'Login' do
    describe 'When invalid credentials' do
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
    end

    it 'Signed in successfully' do
      user = ActiveRecordTestHelpers::FactoryUser.any
      post(
        user_session_path,
        params: auth_params(user)
      )
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Logout' do
    it 'when no active session' do
      delete(destroy_user_session_path)
      expect(response).to have_http_status(:unauthorized)
    end

    let(:logout) do
      lambda { |status|
        delete(destroy_user_session_path, headers: @headers)
        expect(response).to have_http_status(status)
      }
    end

    it 'logged out successfully' do
      authorize
      logout.call(:success)
    end

    it 'when logging out twice' do
      authorize
      logout.call(:success)
      logout.call(:unauthorized)
    end
  end
end
