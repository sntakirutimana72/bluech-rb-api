require 'rails_helper'

RSpec.describe ChatsChannel, type: :channel do
  let(:enqueued_jobs) do
    ActiveJob::Base.queue_adapter.enqueued_jobs
  end

  before do
    stub_connection(current_user: @current_user)
  end

  before(:context) do
    @current_user, @peer = ActiveRecordTestHelpers::FactoryUser.many(2, 'dm')
  end

  after do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  after(:context) do
    purge_all_records
  end

  describe 'When subscribed' do
    it 'successfully subscribes' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(@current_user)
    end

    describe ':typing action' do
      it 'enqueues a job' do
        subscribe
        expect do
          perform(:typing, channelId: @peer.id)
        end.to change(enqueued_jobs, :size).by(1)
      end

      it 'enqueues on :typing_jobs queue' do
        subscribe
        expect do
          perform(:typing, channelId: @peer.id)
        end.to have_enqueued_job
                 .with(@peer, { type: 'typing', author: AuthorSerializer.new(@current_user).as_json })
                 .on_queue(:typing_jobs)
      end
    end
  end
end
