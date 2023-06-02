# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.string :username

    t.integer :company_id
  end
  add_index :users, %i[company_id username], unique: true, name: 'idx_users_on_company_id_username'
  add_index :users, [:name], unique: true, name: 'idx_users_on_name'

  create_table :companies, force: true do |t|
    t.string :name
  end

  add_index :companies, [:name], unique: true, name: 'idx_companies_on_name'
end
