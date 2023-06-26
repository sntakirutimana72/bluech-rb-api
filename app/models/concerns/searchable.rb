module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def exists?(**options)
      !!find_by(options)
    end
  end
end
