module V1
  class ChatsQuartersController < ApplicationController
    before_action :acquire_peer

    def create
      return as_found(quarter: QuarterSerializer.new(@quarter)) unless not_acquainted?

      @quarter = ChatsQuarter.create
      @quarter.members.push(current_user, @peer)
      ChatsQuarterUpdaterJob.notify(@quarter, @peer)
      as_created(quarter: QuarterSerializer.new(@quarter))
    end

    private

    def acquire_peer
      @peer = User.find_by(id: params[:peer_id])
      if @peer.nil?
        as_unprocessable(message: "Resource with :peer_id => #{params[:peer_id]} not found")
      end
    end

    def not_acquainted?
      peers = [current_user, @peer]
      @quarter = ChatsQuarter
                   .joins(:memberships)
                   .where(memberships: { user_id: peers.map(&:id) })
                   .find { |cq| ( peers & cq.members ).many? }
      @quarter.nil?
    end
  end
end
