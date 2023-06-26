require 'rails_helper'

RSpec.describe ChatsQuarter, type: :model do
  context 'When valid' do
    it 'with & without :is_private & :name' do
      expect(described_class.new).to be_valid
      expect(described_class.new(is_private: false, name: 'Amen!')).to be_valid
    end
  end

  context 'Associations' do
    it { should have_many(:chats) }
    it { should have_many(:members) }
    it { should have_many(:memberships) }
  end

  describe 'With :members & :chats' do
    before(:context) do
      @members = ActiveRecordTestHelpers::FactoryUser.many(2)
      @quarter = described_class.create
      @quarter.members.push(*@members)
    end

    after(:context) do
      purge_all_records
    end

    it 'members should have quarters' do
      another_quarter = described_class.create
      another_quarter.members << @members.first

      expect(@members.first.quarters.size).to eq(2)
      expect(@members.last.quarters.size).to eq(1)
    end

    it 'members should have memberships' do
      expect(@members.first.memberships).to exist
      expect(@members.last.memberships).to exist
    end

    it 'should have members' do
      expect(@quarter.members).to eq(@members)
      expect(@quarter.memberships.size).to eq(@members.size)
    end

    it 'should have chats' do
      expect(@members.first.messages).not_to exist
      @members.each { |author| ActiveRecordTestHelpers::FactoryMessage.many(2, author:, channel: @quarter) }
      expect(@members.first.messages).to exist
      expect(@quarter.chats.size).to eq(4)
    end
  end
end
