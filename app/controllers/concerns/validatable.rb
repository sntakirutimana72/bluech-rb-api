module Validatable
  module Message
    include ActiveSupport::Concern

    private

    def validate_convo_params
      return if permittable?(:convo, :channelId)

      as_invalid(error: ':channelId is required')
    end

    def validate_seen_params
      return if (
        permittable?(:convo, :authorId) &&
          params[:convo][:ids].is_a?(Array) && params[:convo][:ids].length.positive?
      )

      as_invalid(error: ':authorId & :ids are required')
    end

    def validate_all_seen_params
      return if permittable?(:convo, :authorId)

      as_invalid(error: ':authorId is required')
    end

    def permittable?(cover, front)
      params[cover].is_a?(ActionController::Parameters) && params[cover][front].to_i.positive?
    end
  end
end
