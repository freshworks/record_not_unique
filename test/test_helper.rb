require_relative '../lib/record_not_unique'
module Rails
  extend self
  module VERSION
    MAJOR = 6
    MINOR = 1
  end
end

class DummyModel
  include ActiveModel::Model
  include RecordNotUnique::InstanceMethods

  attr_accessor :errors

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end
end