require 'rails_helper'

RSpec.describe Message, type: :model do
  after(:context) { purge_all_records }

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

  describe 'Readable' do
    let(:all_ids) { described_class.where(author: @author, recipient: @rec).ids }

    before do
      @author = User.create(name: 'Tester-1', email: 'tester-1@gmail.com', password: 'pass@123')
      @rec = User.create(name: 'Tester-2', email: 'tester-2@gmail.com', password: 'pass@123')

      described_class.create(
        [
          {recipient: @rec, author: @author, desc: 'Test mark_as_read scope', seen_at: Time.now},
          {recipient: @rec, author: @author, desc: 'Test mark_as_read scope'},
          {recipient: @rec, author: @author, desc: 'Test mark_as_read scope'}
        ]
      )
    end

    after { purge_all_records }

    it '#mark_as_read all given ids referencing unread messages' do
      # Invoke #mark_as_read
      results = described_class.mark_as_read([all_ids.join(','), @author.id, @rec.id])
      marked_ids = results.rows.map(&:first)
      # Assert expectation
      expect(all_ids).not_to eq(marked_ids)
      expect(all_ids[1..]).to eq(marked_ids)
    end

    it '#mark_all_as_read marks all existing messages as seen' do
      # Invoke #mark_all_as_read
      results = described_class.mark_all_as_read([@author.id, @rec.id])
      marked_ids = results.rows.map(&:first)
      # Assert expectation
      expect(all_ids).not_to eq(marked_ids)
      expect(all_ids[1..]).to eq(marked_ids)
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
