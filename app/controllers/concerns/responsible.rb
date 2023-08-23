module Responsible
  include ActiveSupport::Concern

  private

  def as_success(status: :ok, **options)
    render(json: options, status:)
  end

  def as_created(**options)
    as_success(**options, status: :created)
  end

  def as_found(**options)
    as_success(**options, status: :found)
  end

  def as_unauthorized(**options)
    as_success(**options, status: :unauthorized)
  end

  def as_invalid(**options)
    as_success(**options, status: :bad_request)
  end

  def as_unavailable(**options)
    as_success(**options, status: :not_found)
  end

  def as_unprocessable(**options)
    as_success(**options, status: :unprocessable_entity)
  end
end
