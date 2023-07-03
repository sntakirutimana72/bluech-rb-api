require 'rails_helper'

RSpec.describe User, type: :model do
  let(:options) { ActiveRecordTestHelpers::FactoryUser.any_options }

  let(:tmp_user) { described_class.new(options) }

  it 'should be valid' do
    expect(tmp_user).to be_valid
  end

  describe 'Associations' do
    it { should have_many(:inbounds) }
    it { should have_many(:messages) }
  end

  describe 'When arguments are invalid' do
    it { expect(described_class.new).to_not be_valid }

    context 'When :name is invalid' do
      it 'omitted' do
        options.delete(:name)
        expect(tmp_user).to_not be_valid
      end

      it 'too short' do
        options[:name] = 'Hi'
        expect(tmp_user).to_not be_valid
      end

      it 'too long' do
        options[:name] = 'Hi' * 13
        expect(tmp_user).to_not be_valid
      end
    end

    context 'When :email is invalid' do
      it 'empty' do
        options[:email] = ''
        expect(tmp_user).to_not be_valid
      end

      it 'omitted' do
        options.delete(:email)
        expect(tmp_user).to_not be_valid
      end

      it 'broken pattern' do
        options[:email] = 'hello@'
        expect(tmp_user).to_not be_valid
      end
    end

    context 'When :password is invalid' do
      it 'empty' do
        options[:password] = ''
        expect(tmp_user).to_not be_valid
      end

      it 'omitted' do
        options.delete(:password)
        expect(tmp_user).to_not be_valid
      end

      it 'too short' do
        options[:password] = '123'
        expect(tmp_user).to_not be_valid
      end

      it 'too long' do
        options[:password] = '1' * 130
        expect(tmp_user).to_not be_valid
      end
    end
  end
end
