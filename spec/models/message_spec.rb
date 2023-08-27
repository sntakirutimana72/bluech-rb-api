require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'Associations' do
    it { should belong_to(:author) }
    it { should belong_to(:recipient) }
  end

  describe 'Trackable' do
    before(:context) do
      generate_user = ->(name) { { name:, email: "#{name.downcase}@gmail.com", password: 'pass@123' }  }
      @people = User.create(%w(Steve Jim Eric Zus Zoe).map(&generate_user) )

      recipient = @people.first
      static_desc = %w(Hi Hello Hey Greetings Bonjour)
      generate_msg = ->(num, author) { { desc: static_desc[num], recipient:, author: } }
      @people[1..].each { |u| described_class.create(rand(1..5).times.map { |i| generate_msg.(i, u) }) }
    end

    after(:context) { purge_all_records }

    it 'queries a conversation history' do
      recipient = @people[1]
      me = @people.first
      all_counts = (me.messages.where(recipient:) + me.inbounds.where(author: recipient)).count
      convo = described_class.conversation({ me: me.id, channelId: recipient.id })

      expect(convo.length).to eq(all_counts)
    end

    it 'queries inbox previews' do
      me = @people.first
      inbox = described_class.inbox(me.id)
      latest = InboxSerializer.new(inbox.first).as_json

      expect(inbox.length).to eq(@people.length - 1)
      fiq = described_class.where(author_id: latest[:id], seen_at: nil).order(created_at: :desc)
      expect(latest[:unread]).to eq(fiq.count)
      expect(latest[:preview]).to eq(fiq.first.desc)
    end

    it 'inbox query does not include self-sent message previews' do
      author = @people.first
      inbox_count_before = described_class.inbox(author.id)&.length
      described_class.create(author:, recipient: author, desc: 'Been better!')
      inbox_count_after = described_class.inbox(author.id)&.length

      expect(inbox_count_before).to eq(inbox_count_after)
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
