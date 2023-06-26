module Responsible
  include ActiveSupport::Concern

  private

  def as_success(status: :ok, **options)
    render(json: options, status:)
  end

  def as_created(**options)
    as_success(status: :created, **options)
  end

  def as_found(**options)
    as_success(status: :found, **options)
  end

  def as_unauthorized(message: 'Unauthorized', **options)
    as_success(status: :unauthorized, message:, **options)
  end

  def as_unavailable(**options)
    as_success(status: :not_found, **options)
  end

  def as_unprocessable(**options)
    as_success(status: :unprocessable_entity, **options)
  end
end
