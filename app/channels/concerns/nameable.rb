module Nameable
  NAMESPACE_SEP = '_'.freeze

  module Peer2PeerNomenclature
    include ActiveSupport::Concern

    protected

    NAMESPACE_SUFFIX = 'dm'.freeze

    def peer2peer_namespace(peer)
      naming_options(peer).join(NAMESPACE_SEP)
    end

    def naming_options(peer)
      [NAMESPACE_SUFFIX, current_user.id, peer]
    end
  end
end
