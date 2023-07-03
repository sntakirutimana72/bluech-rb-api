require 'rails_helper'

RSpec.describe V1::MessagesController, type: :request do
  before(:context) do
    purge_all_records
    @users = ActiveRecordTestHelpers::FactoryUser.many(3)
    @msg_size = 0
    @users[1..].each do |author|
      @msg_size += 2
      ActiveRecordTestHelpers::FactoryMessage.any(
        author:, recipient: @users.first
      )
      ActiveRecordTestHelpers::FactoryMessage.any(author: @users.first, recipient: author)
    end
  end

  after(:context) do
    purge_all_records
  end

  context 'When no authorization' do
    it 'GET /v1/messages' do
      get v1_messages_path
      expect(response).to have_http_status(:unauthorized)
    end

    it 'POST /v1/messages' do
      post(v1_messages_path, params: msg_params, as: :json)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'When authorized' do
    before(:context) { authorize(@users.first) }

    it 'fetches chats' do
      get(v1_messages_path, headers: @headers)
      load_body(:request)
      expect(response).to have_http_status(:success)
      expect(@body['chats'].size).to eq(@msg_size)
    end

    it 'fails to create new message, bad :desc' do
      post(
        v1_messages_path,
        headers: @headers,
        params: msg_params(desc: '', recipient_id: @users.last.id), as: :json
      )
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'successfully created new message' do
      post(
        v1_messages_path,
        headers: @headers,
        params: msg_params(recipient_id: @users.last.id), as: :json
      )
      expect(response).to have_http_status(:created)
    end

    it 'ChatsJob to enqueue a job' do
      expect do
        post(
          v1_messages_path,
          headers: @headers,
          params: msg_params(recipient_id: @users.last.id), as: :json
        )
      end.to have_enqueued_job(ChatsRelayJob).on_queue(:default)
    end
  end
end
