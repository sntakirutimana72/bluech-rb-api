require 'rails_helper'

RSpec.describe V1::InboxController, type: :request do
  describe 'GET /index' do
    before(:context) do
      users_meta = 5.times.map do |i|
        { name: "Steve#{i + 1}", email: "steve#{i + 1}@gmail.com", password: 'pass@123' }
      end
      @people = User.create(users_meta)
      @me = @people.first
      @people[1..].each do |author|
        Message.create(rand(1..5).times.map { |i| { desc: "Hi-#{i + 1}!", recipient: @me, author: } })
      end
    end

    after(:context) { purge_all_records }

    it 'fails to load previews without authorization' do
      get v1_inbox_path
      expect(response).to have_http_status(:unauthorized)
    end

    it 'successfully loads previews' do
      authorize(@me)
      get(v1_inbox_path, headers: @headers)
      expect(response).to have_http_status(:ok)
      expect(load_body(:request)).to include('previews')
      expect(@body['previews'].length).to eq(@people.length - 1)

      latest = @body['previews'].first
      fiq = Message.where(author_id: latest['id']).order(created_at: :desc)

      expect(latest['unread']).to eq(fiq.count)
      expect(latest['preview']).to eq(fiq.first.desc)
    end
  end
end
