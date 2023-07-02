module V1
  class ChatsQuartersController < ApplicationController
    before_action :acquire_peer, only: :create

    def index
      as_success(channels: ListSerializer.new(current_user.quarters))
    end

    def create
      return as_found(quarter: ChatsQuarterSerializer.new(@quarter)) unless not_acquainted?

      @quarter = ChatsQuarter.create
      @quarter.members.push(current_user, @peer)
      ChatsQuarterUpdaterJob.notify(@quarter, @peer)
      as_created(quarter: ChatsQuarterSerializer.new(@quarter))
    end

    private

    def acquire_peer
      @peer = User.find_by(id: params[:peer_id])
      return unless @peer.nil?

      as_unprocessable(error: "Resource with :peer_id => #{params[:peer_id]} not found")
    end

    def not_acquainted?
      peers = [current_user, @peer]
      @quarter = ChatsQuarter
        .joins(:memberships)
        .where(memberships: { user_id: peers.map(&:id) })
        .find { |cq| (peers & cq.members).many? }
      @quarter.nil?
    end
  end
end
