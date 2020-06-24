# frozen_string_literal: true

require 'active_record'
require 'record_not_unique'

shared_context 'use connection', use_connection: true do
  db_name = 'rnu_test'
  options = {
    adapter: 'mysql2', database: '', username: 'root', password: '', pool: 5
  }
  
  ActiveRecord::Base.establish_connection(options)
  ActiveRecord::Base.connection.create_database db_name
  options[:database] = db_name

  ActiveRecord::Base.establish_connection(options)
  
  load File.dirname(__FILE__) + '/schema.rb'

  require File.dirname(__FILE__) + '/models.rb'

  after(:all) do
    ActiveRecord::Base.connection.drop_database(db_name)
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
end