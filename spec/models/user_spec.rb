require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'With_valid_arguments' do
    subject { described_class.new(name: 'test_user') }

    it { should be_valid }
  end

  describe 'Associations' do
    it { should have_many(:outbounds) }
    it { should have_many(:inbounds) }
  end

  describe 'With_invalid_arguments' do
    it { expect(described_class.new).to_not be_valid }
    it { expect(described_class.new(name: 'Hi')).to_not be_valid }

    it do
      instance = described_class.new(name: 'Hi' * 13)
      expect(instance).to_not be_valid
    end
  end
end
