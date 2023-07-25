require 'rails_helper'

RSpec.describe Users::AccountsController, type: :request do
  before(:context) do
    @user = ActiveRecordTestHelpers::FactoryUser.any(email: 'woow@email.test')
  end

  after(:context) do
    purge_all_records
  end

  let(:assert_user_info) do
    expect(response).to have_http_status(:ok)
    token = response.headers['Authorization']
    expect(token).to be_a(String)
  end

  let(:assert_user_info_with_auth) do
    assert_user_info
    expect(token).not_to eq(@headers[:Authorization])
  end

  context '/users/account' do
    it 'when no authorization' do
      get user_profile_path
      expect(response).to have_http_status(:unauthorized)
    end

    it 'when fake authorization' do
      fake_authorize
      get(user_profile_path, headers: @headers)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'successfully retrieved profile' do
      authorize(@user)
      get(user_profile_path, headers: @headers)
      assert_user_info
    end
  end

  context '/users/refresh_session' do
    it 'successfully refreshed' do
      authorize(@user)
      head(refresh_user_session_path, headers: @headers)
      assert_user_info_with_auth
    end

    it 'fails on authentication' do
      fake_authorize
      head(refresh_user_session_path, headers: @headers)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context '/users/signed_user' do
    it 'successfully refreshed' do
      authorize(@user)
      get(session_signed_user_path, headers: @headers)
      assert_user_info_with_auth
    end

    it 'fails on authentication' do
      fake_authorize
      head(session_signed_user_path, headers: @headers)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
