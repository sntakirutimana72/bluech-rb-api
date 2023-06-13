require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    @usr = User.new(name: 'test_sender')
    @rusr = User.new(name: 'test_recipient')
  end

  describe 'With_valid_arguments' do
    subject do
      described_class.new(desc: 'Hey!', sender: @usr, recipient: @rusr)
    end

    it { should be_valid }
    it { expect(subject.desc.length).to be >= 1 }
    it { expect(subject.sender).to be(@usr) }
    it { expect(subject.recipient).to be(@rusr) }
  end

  describe 'Associations' do
    it { should belong_to(:sender) }
    it { should belong_to(:recipient) }
  end

  describe 'With_invalid_arguments' do
    it do
      without_desc = described_class.new(sender: @usr, recipient: @rusr)
      expect(without_desc).to_not be_valid
    end

    it do
      without_sender = described_class.new(desc: 'Hi', recipient: @rusr)
      expect(without_sender).to_not be_valid
    end

    it do
      without_rec = described_class.new(desc: 'Hi', sender: @usr)
      expect(without_rec).to_not be_valid
    end
  end
end
