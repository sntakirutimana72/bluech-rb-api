require 'rails_helper'

RSpec.describe AccountsController, type: :request do
  describe 'Invalid Authorization' do
    it 'when no authorization' do
      get user_profile_path
      expect(response).to have_http_status(:unauthorized)
    end

    it 'when fake authorization' do
      fake_authorize
      get(user_profile_path, headers: @headers)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'Acceptable Authorization' do
    after do
      purge_all_records
    end

    it do
      authorize
      get(user_profile_path, headers: @headers)
      expect(response).to have_http_status(:success)
    end
  end
end
