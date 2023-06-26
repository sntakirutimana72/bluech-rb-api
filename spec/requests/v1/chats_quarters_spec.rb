require 'rails_helper'

RSpec.describe V1::ChatsQuartersController, type: :request do
  before(:all) do
    @users = ActiveRecordTestHelpers::FactoryUser.many(4)
    @quarter = ChatsQuarter.create(name: 'quarter_x_y')
    @quarter.members.push(*@users.first(2))
    authorize(@users.first)
  end

  after(:all) do
    purge_all_records
  end

  it ':unprocessable entity coz peer not found' do
    post(
      v1_chats_quarters_path,
      headers: @headers,
      as: :json
    )
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'found an existing resource' do
    post(
      v1_chats_quarters_path,
      headers: @headers,
      params: { peer_id: @users[1].id },
      as: :json
    )
    expect(response).to have_http_status(:found)
  end

  it 'created successfully' do
    post(
      v1_chats_quarters_path,
      headers: @headers,
      params: { peer_id: @users[2].id },
      as: :json
    )
    expect(response).to have_http_status(:created)
  end

  it 'ChatsQuarterUpdaterJob to enqueue a job' do
    expect {
      post(
        v1_chats_quarters_path,
        headers: @headers,
        params: { peer_id: @users.last.id },
        as: :json
      )
    }.to have_enqueued_job(ChatsQuarterUpdaterJob)
  end
end
