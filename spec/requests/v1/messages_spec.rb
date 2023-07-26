require 'rails_helper'

RSpec.describe V1::MessagesController, type: :request do
  before(:context) do
    max_count = 3
    @users = ActiveRecordTestHelpers::FactoryUser.many(max_count, 'convo')
    @me = @users.first
    @msg_size = 2 * (max_count - 1)
    @users[1..].each do |author|
      ActiveRecordTestHelpers::FactoryMessage.any(author:, recipient: @me, desc: 'Hey!')
      ActiveRecordTestHelpers::FactoryMessage.any(author: @me, recipient: author)
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
    before(:context) { authorize(@me) }

    it 'successfully loads conversation history' do
      channel = @users.last
      get(
        v1_messages_path,
        headers: @headers,
        params: { convo: { channel: channel.id } }
      )
      expect(response).to have_http_status(:success)
      all_counts = (channel.inbounds.where(author: @me) + channel.messages.where(recipient: @me)).count
      expected_pages_count = (all_counts / 50.to_f).ceil
      expect(load_body(:request)).to include('chats')
      expect(@body).to include('pagination')
      expect(@body['pagination']['current']).to be(1)
      expect(@body['pagination']['pages']).to be(expected_pages_count)
    end

    it 'fails to load conversation, when missing :channel param' do
      get(v1_messages_path, headers: @headers, params: { convo: nil })
      expect(response).to have_http_status(:bad_request)
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
