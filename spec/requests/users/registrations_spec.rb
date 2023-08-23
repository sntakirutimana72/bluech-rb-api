require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :request do
  after(:all) do
    purge_all_records
  end

  it 'when invalid arguments' do
    post(user_registration_path, params: user_params(name: ''), as: :json)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'when valid arguments' do
    post(user_registration_path, params: user_params, as: :json)
    expect(response).to have_http_status(:created)
    expect(response).to include('Authorization')
  end
end
