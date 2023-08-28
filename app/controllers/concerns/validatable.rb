module Validatable
  module Message
    include ActiveSupport::Concern

    private

    def validate_convo_params
      return if permittable?(:convo) && params[:convo][:channelId].to_i.positive?

      as_invalid(error: ':channelId is required')
    end

    def validate_seen_params
      return if (
        permittable?(:convo) &&
        params[:convo][:authorId].to_i.positive? &&
        params[:convo][:ids].is_a?(Array) && params[:convo][:ids].length.positive?
      )

      as_invalid(error: ':authorId & :ids are required')
    end

    def permittable?(key)
      params[key].is_a?(ActionController::Parameters)
    end
  end
end
