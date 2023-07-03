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

  context 'When subscribed' do
    it 'successfully subscribes' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(@current_user)
    end

    it ':typing action enqueues a job' do
      subscribe
      expect {
        perform(:typing, channel_id: @peer.id)
      }.to change(enqueued_jobs, :size).by(1)
    end

    it ':typing action enqueues on :typing_jobs queue' do
      subscribe
      expect {
        perform(:typing, channel_id: @peer.id)
      }.to have_enqueued_job
             .with(@peer, { type: 'typing', author: AuthorSerializer.new(@current_user).as_json })
             .on_queue(:typing_jobs)
    end
  end
end
