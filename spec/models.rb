# frozen_string_literal: true

class Company < ActiveRecord::Base
  handle_record_not_unique(index: 'idx_companies_on_name', message: {name: :taken})

  has_many :users
end

class User < ActiveRecord::Base
  handle_record_not_unique(
    {
      index: 'idx_users_on_company_id_username', message: {
      username: ->(user) { "not available for #{user.company.name}" }
    }
    },
    { index: 'idx_users_on_name', message: {name: :taken} }
  )

  belongs_to :company
end

class Product < ActiveRecord::Base
  handle_record_not_unique(
    {
      index: 'idx_products_on_name', message: {
      name: { message: :taken, code: :conflict }
    }
    },
    { index: 'idx_users_on_name', message: {name: :taken} }
  )
end