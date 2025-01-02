require 'minitest/autorun'
require 'active_record'
require_relative '../test_helper'

class RecordNotUniqueTest < Minitest::Test

  def setup
    @model = DummyModel.new
    @original_major_version = Rails::VERSION::MAJOR
  end

  def teardown
    Rails::VERSION.const_set(:MAJOR, @original_major_version)
  end

  def test_add_custom_error_with_hash_rails_6
      @model.send(:add_custom_error, :base, { message: 'error_message' })
      assert_equal({base: ['error_message']}, @model.errors.messages)
  end

  def test_add_custom_error_with_string_rails_6
    @model.send(:add_custom_error, :base, 'error_message')
    assert_equal({base: ['error_message']}, @model.errors.messages)
  end

  def test_add_custom_error_with_hash_rails_5
    Rails::VERSION.const_set(:MAJOR, 5)
    @model.send(:add_custom_error, :base, { message: 'error_message' })
    assert_equal({base: ['error_message']}, @model.errors.messages)
  end

  def test_add_custom_error_with_string_rails_5
    Rails::VERSION.const_set(:MAJOR, 5)
    @model.send(:add_custom_error, :base, 'error_message')
    assert_equal({base: ['error_message']}, @model.errors.messages)
  end
end