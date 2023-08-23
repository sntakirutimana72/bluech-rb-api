require 'rails_helper'

RSpec.describe Users::PeopleController, type: :request do
  describe 'GET /users' do
    it 'fails without authorization' do
      get people_repo_path
      expect(response).to have_http_status(:unauthorized)
    end

    describe 'successfully retrieves people' do
      before(:context) do
        @pagy_limit = 5
        @count = (@pagy_limit * 3) + 2
        @people = ActiveRecordTestHelpers::FactoryUser.many(@count, 'peo')
      end

      before { authorize(@people.first) }

      after(:context) do
        purge_all_records
      end

      let(:meet_expectations) do
        lambda { |page_count, page_num|
          expect(response).to have_http_status(:ok)
          expect(load_body(:request)).to include('people')
          expect(@body).to include('pagination')
          expect(@body['people'].length).to eq(page_count)
          expect(@body['pagination']['current']).to eq(page_num)
        }
      end

      it 'queries first page without :page query parameter' do
        get(people_repo_path, headers: @headers)
        meet_expectations.call(@pagy_limit, 1)
      end

      it 'respects :page when given' do
        page = (@count / @pagy_limit.to_f).ceil
        faulty_size = @count % @pagy_limit
        expected_people_size = faulty_size.zero? ? @pagy_limit : faulty_size

        get(people_repo_path, headers: @headers, params: { page: })
        meet_expectations.call(expected_people_size, page)
      end
    end
  end
end
