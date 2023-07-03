require 'rails_helper'

RSpec.describe ChatsChannel, type: :channel do
  before do
    stub_connection(current_user: @current_user)
  end

  before(:context) do
    @current_user, @peer = ActiveRecordTestHelpers::FactoryUser.many(2, 'dm')
    @quarters = [ChatsQuarter.create]
    @quarters.first.members.push(@current_user, @peer)
    @quarters << ChatsQuarter.create
    @quarters.last.members << @current_user
  end

  after(:context) do
    purge_all_records
  end

  context 'Subscription' do
    it 'should be streaming on two quarters' do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(@current_user)
      expect(subscription).to have_stream_for(@quarters.first)
      expect(subscription).to have_stream_for(@quarters.last)
    end
  end
end
