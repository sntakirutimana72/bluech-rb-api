require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'Associations' do
    it { should belong_to(:author) }
    it { should belong_to(:channel) }
  end

  describe 'Shared Parameters' do
    before(:context) do
      @user_x, @user_y = ActiveRecordTestHelpers::FactoryUser.many(2)
      @channel = ChatsQuarter.create
      @channel.members << @user_y
    end

    after(:context) do
      purge_all_records
    end

    describe 'When valid' do
      subject do
        described_class.new(desc: 'Hey!', author: @user_y, channel: @channel)
      end

      it { should be_valid }
    end

    describe 'When invalid' do
      it 'without :membership' do
        expect(described_class.new(desc: 'Hi', author: @user_x, channel: @channel)).to_not be_valid
      end

      it 'without :author' do
        expect(described_class.new(desc: 'Hey!', channel: @channel)).to_not be_valid
      end

      it 'without :channel' do
        expect(described_class.new(desc: 'Hey!', author: @user_y)).to_not be_valid
      end

      it 'bad :desc' do
        expect(described_class.new(author: @user_y, channel: @channel)).not_to be_valid
        expect(described_class.new(desc: '', author: @user_y, channel: @channel)).not_to be_valid
      end
    end
  end
end
