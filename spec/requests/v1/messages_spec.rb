require 'rails_helper'

RSpec.describe V1::MessagesController, type: :request do
  before(:context) do
    @users = ActiveRecordTestHelpers::FactoryUser.many(3)
    @quarter = ChatsQuarter.create(name: 'quarter_x_y')
    @quarter.members.push(*@users[..1])

    @messages_size = 0
    @users[..1].each do |author|
      @messages_size += ActiveRecordTestHelpers::FactoryMessage.many(2, author:, channel: @quarter).size
    end
  end

  after(:context) do
    purge_all_records
  end

  describe 'Unauthorized' do
    it 'GET /v1/quarters/chats/:chats_quarter_id/messages' do
      get v1_chats_quarter_messages_path(@quarter)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'POST /v1/quarters/chats/:chats_quarter_id/messages' do
      post(
        v1_chats_quarter_messages_path(@quarter),
        params: msg_params,
        as: :json
      )
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'Authorized but with bad params' do
    before(:context) { authorize(@users.first) }

    context "Quarter doesn't exist" do
      it 'retrieve chats' do
        get(
          v1_chats_quarter_messages_path(0),
          headers: @headers
        )
        expect(response).to have_http_status(:not_found)
      end

      it 'direct message' do
        post(
          v1_chats_quarter_messages_path(0),
          headers: @headers,
          params: msg_params,
          as: :json
        )
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'no membership' do
      before(:context) { authorize(@users.last) }

      it 'retrieve chats' do
        get(
          v1_chats_quarter_messages_path(@quarter),
          headers: @headers
        )
        expect(response).to have_http_status(:unauthorized)
      end

      it 'direct message' do
        post(
          v1_chats_quarter_messages_path(@quarter),
          headers: @headers,
          params: msg_params,
          as: :json
        )
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with right authorization & membership' do
      it 'successfully retrieved chats' do
        get(v1_chats_quarter_messages_path(@quarter), headers: @headers)
        expect(response).to have_http_status(:success)
      end

      it 'message not created' do
        post(
          v1_chats_quarter_messages_path(@quarter),
          headers: @headers,
          params: msg_params(desc: ''), as: :json
        )
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'created successfully direct message' do
        post(
          v1_chats_quarter_messages_path(@quarter),
          headers: @headers,
          params: msg_params, as: :json
        )
        expect(response).to have_http_status(:created)
      end

      it 'ChatsRelayJob to enqueue a job' do
        expect do
          post(
            v1_chats_quarter_messages_path(@quarter),
            headers: @headers,
            params: msg_params, as: :json
          )
        end.to have_enqueued_job(ChatsRelayJob)
      end
    end
  end
end
