require 'rails_helper'

RSpec.describe V1::MessagesController, type: :request do
  before(:context) do
    @current_user = ActiveRecordTestHelpers::FactoryUser.any
    @another_user = ActiveRecordTestHelpers::FactoryUser.any(email: 'tester-2@gmail.com')
  end

  after(:context) do
    purge_all_records
  end

  describe 'When no authorization' do
    it 'fails to retrieve chatroom conversation' do
      get v1_messages_path
      expect(response).to have_http_status(:unauthorized)
    end

    it 'fails to create a new message' do
      post(v1_messages_path, params: msg_params, as: :json)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'fails to mark messages as read' do
      post(v1_mark_as_read_path, params: {convo: {ids: [11], authorId: 3}}, as: :json)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'When authorized' do
    before(:context) { authorize(@current_user) }

    after do
      Message.destroy_all
    end

    describe 'Load conversation' do
      it 'successfully loads conversation history' do
        # Generate conversation
        expected_counter = 3
        ActiveRecordTestHelpers::FactoryMessage.many(
          expected_counter - 1, {author: @current_user, recipient: @another_user}
        )
        ActiveRecordTestHelpers::FactoryMessage.any(recipient: @current_user, author: @another_user)
        # Send a request to retrieve convo history
        get(v1_messages_path, headers: @headers, params: { convo: { channelId: @another_user.id } })
        # Assert response status
        expect(response).to have_http_status(:success)
        # Calculate expected :pages in pagination from :another_counter
        expected_pages = (expected_counter / 50.to_f).ceil
        # Finally, assert
        expect(load_body(:request)).to include('chats')
        expect(@body).to include('pagination')
        expect(@body['pagination']['current']).to be(1)
        expect(@body['pagination']['pages']).to be(expected_pages)
        expect(@body['chats'].length).to eq(expected_counter)
      end

      it 'fails to load conversation, when missing :channelId param' do
        get(v1_messages_path, headers: @headers, params: { convo: nil })
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'Create a new message' do
      it 'fails to create new message, bad :desc' do
        post(
          v1_messages_path,
          headers: @headers,
          params: msg_params(desc: '', recipient_id: @another_user.id), as: :json
        )
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'creates new message successfully' do
        post(
          v1_messages_path,
          headers: @headers,
          params: msg_params(recipient_id: @another_user.id), as: :json
        )
        expect(response).to have_http_status(:created)
      end

      it 'enqueues a job on successful creation of new message' do
        expect do
          post(
            v1_messages_path,
            headers: @headers,
            params: msg_params(recipient_id: @another_user.id), as: :json
          )
        end.to have_enqueued_job(ChatsRelayJob).on_queue(:default)
      end
    end

    describe 'Mark as read' do
      let(:params) { {convo: {authorId: @another_user.id, ids: @ids}} }

      before do
        @ids = ActiveRecordTestHelpers::FactoryMessage.many(
          2,
          {recipient: @current_user, author: @another_user}
        ).map(&:id)
      end

      after do
        Message.destroy_all
      end

      describe 'Bad params' do
        it 'fails when :convo missing' do
          post(v1_mark_as_read_path, headers: @headers)
          expect(response).to have_http_status(:bad_request)
        end

        it 'fails when :convo is not of Hash type' do
          post(v1_mark_as_read_path, headers: @headers, params: {convo: nil}, as: :json)
          expect(response).to have_http_status(:bad_request)
        end

        it 'fails when missing :authorId in params' do
          params[:convo].delete(:authorId)
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
          expect(response).to have_http_status(:bad_request)
        end

        it 'fails when :authorId is a non positive digit' do
          params[:convo][:authorId] = 0
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
          expect(response).to have_http_status(:bad_request)
        end

        it 'fails when missing :ids in params' do
          params[:convo].delete(:ids)
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
          expect(response).to have_http_status(:bad_request)
        end

        it 'fails when :ids is not an array' do
          params[:convo][:ids] = 2
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
          expect(response).to have_http_status(:bad_request)
        end

        it 'fails when :ids is an empty array' do
          params[:convo][:ids] = []
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
          expect(response).to have_http_status(:bad_request)
        end
      end

      it 'succeeds with effect' do
        post(v1_mark_as_read_path, headers: @headers, params:, as: :json)

        expect(response).to have_http_status(:success)
        expect(load_body(:request)).to include('ids')
        expect(@body['ids']).to eq(@ids)
      end

      it 'enqueues a job when there was effect' do
        expect do
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
        end.to have_enqueued_job
      end

      it 'succeeds without effect' do
        params[:convo][:ids] = ActiveRecordTestHelpers::FactoryMessage.many(
          2,
          { recipient: @current_user, author: @another_user, seen_at: Time.now }
        ).map(&:id)
        post(v1_mark_as_read_path, headers: @headers, params:, as: :json)

        expect(response).to have_http_status(:success)
        expect(load_body(:request)).to include('ids')
        expect(@body['ids'].length).to eq(0)
      end

      it 'does not enqueue a job when there was no effect' do
        params[:convo][:ids] = ActiveRecordTestHelpers::FactoryMessage.many(
          2,
          { recipient: @current_user, author: @another_user, seen_at: Time.now }
        ).map(&:id)

        expect do
          post(v1_mark_as_read_path, headers: @headers, params:, as: :json)
        end.not_to have_enqueued_job
      end
    end
  end
end
