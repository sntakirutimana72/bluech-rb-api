require 'rails_helper'

describe ChatsRelayJob, type: :job do
  let(:enqueued_jobs) do
    ActiveJob::Base.queue_adapter.enqueued_jobs
  end

  before(:context) do
    @current_user, @peer = ActiveRecordTestHelpers::FactoryUser.many(2, 'jb')
  end

  after do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  after(:context) { purge_all_records }

  describe ':relay' do
    let(:resource) do
      ActiveRecordTestHelpers::FactoryMessage.any(author_id: @current_user.id, recipient_id: @peer.id)
    end

    after { resource.destroy }

    it 'enqueues a job on :default queue' do
      expect do
        described_class.relay(resource)
      end.to have_enqueued_job
               .with(resource.recipient, { type: 'message', message: MessageSerializer.new(resource).as_json })
               .on_queue(:default)
    end
  end

  describe ':read' do
    let(:options) { {author_id: @peer.id, recipient_id: @current_user.id} }

    it 'does not enqueue without :ids' do
      expect { described_class.read(**options) }.not_to have_enqueued_job
    end

    it 'enqueues a job on :default queue' do
      ids = %w(1 2 3)
      expect do
        described_class.read(ids:, **options)
      end.to have_enqueued_job
               .with(@peer, { type: 'read', readerId: @current_user.id, ids: })
               .on_queue(:default)
    end
  end

  describe ':typing' do
    it "doesn't enqueue when :channelId doesn't refer to any user" do
      expect do
        described_class.typing({action: 'typing', status: false}, @current_user)
      end.not_to have_enqueued_job
    end

    it 'enqueues a job on :typing_jobs queue' do
      expect do
        described_class.typing({"action"=>'typing', "channelId"=>@peer.id}, @current_user)
      end.to have_enqueued_job
               .with(@peer, {type: 'typing', author: AuthorSerializer.new(@current_user).as_json})
               .on_queue(:typing_jobs)
    end
  end
end
