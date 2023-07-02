require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  it 'rejects connection' do
    expect { connect '/cable' }.to have_rejected_connection
  end

  it 'successfully connects' do
    authorize
    connect("/cable?X-Token=#{@headers['Authorization']}")
    expect(connection.current_user).to eq(@current_user)
  end
end
