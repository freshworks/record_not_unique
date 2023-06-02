# frozen_string_literal: true

class Company < ActiveRecord::Base
  handle_record_not_unique(field: ['name'], message: { name: :taken })

  has_many :users
end

class User < ActiveRecord::Base
  handle_record_not_unique(
    {
      field: %w[company_id username], message: {
        username: ->(user) { "not available for #{user.company.name}" }
      }
    },
    { field: ['name'], message: { name: :taken } }
  )

  belongs_to :company
end
