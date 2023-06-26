module ActiveRecordTestHelpers
  class FactoryUser
    def self.any_options(options = {})
      {
        name: 'any_user',
        email: 'any_user@email.test',
        password: 'pass@123',
        **options
      }
    end

    def self.any(options = {})
      User.create!(any_options(options))
    end

    def self.many(num, prefix = '')
      raise ':num must be an integer > 0' unless num.is_a?(Integer) && num.positive?

      options = num.times.map { |j| any_options(email: "user_#{prefix}#{j + 1}@email.test") }
      User.create!(options)
    end
  end

  class FactoryMessage
    def self.any_options(options = {})
      {
        desc: 'Hi!',
        **options
      }
    end

    def self.any(options = {})
      unless options.key?(:author) || options.key?(:author_id)
        options[:author] = ActiveRecordTestHelpers::FactoryUser.any
      end

      Message.create!(options)
    end

    def self.many(num, options = {})
      raise ':num must be an integer > 0' unless num.is_a?(Integer) && num.positive?

      Message.create!(num.times.map { |_| any_options(options) })
    end
  end

  def purge_all_records
    Message.destroy_all
    Membership.destroy_all
    ChatsQuarter.destroy_all
    User.destroy_all
  end
end
