require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'Associations' do
    it { should belong_to(:author) }
    it { should belong_to(:recipient) }
  end

  describe 'Trackable' do
    before(:context) do
      users_meta = 5.times.map do |i|
        { name: "Steve#{i + 1}", email: "steve#{i + 1}@gmail.com", password: 'pass@123' }
      end
      @people = User.create(users_meta)
      recipient = @people.first
      @people[1..].each do |author|
        described_class.create(rand(1..5).times.map { |i| { desc: "Hi-#{i + 1}!", recipient:, author: } })
      end
    end

    after(:context) { purge_all_records }

    it 'successfully queries a conversation history' do
      recipient = @people[1]
      me = @people.first
      all_counts = (me.messages.where(recipient:) + me.inbounds.where(author: recipient)).count
      convo = described_class.conversation({ me: me.id, channelId: recipient.id })

      expect(convo.length).to eq(all_counts)
    end

    it 'previews inbox' do
      me = @people.first
      inbox = described_class.inbox(me.id)
      latest = InboxSerializer.new(inbox.first).as_json

      expect(inbox.length).to eq(@people.length - 1)
      fiq = described_class.where(author_id: latest[:id]).order(created_at: :desc)
      expect(latest[:unread]).to eq(fiq.count)
      expect(latest[:preview]).to eq(fiq.first.desc)
    end
  end

  describe 'Shared Parameters' do
    before(:context) do
      @user_x, @user_y = ActiveRecordTestHelpers::FactoryUser.many(2)
    end

    after(:context) do
      purge_all_records
    end

    describe 'When valid' do
      subject do
        described_class.new(desc: 'Hey!', author: @user_y, recipient: @user_x)
      end

      it { should be_valid }
    end

    describe 'When invalid' do
      it 'without :author' do
        expect(described_class.new(desc: 'Hey!', recipient: @user_y)).to_not be_valid
      end

      it 'without :recipient' do
        expect(described_class.new(desc: 'Hey!', author: @user_y)).to_not be_valid
      end

      it 'bad :desc' do
        expect(described_class.new(author: @user_y, recipient: @user_x)).not_to be_valid
        expect(described_class.new(desc: '', author: @user_y, recipient: @user_x)).not_to be_valid
      end
    end
  end
end
