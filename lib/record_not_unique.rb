# frozen_string_literal: true

module RecordNotUnique
  # This module provides methods for handling record not unique errors.
  module ClassMethods
    # Handles the record not unique errors for the specified fields and error messages.
    def handle_record_not_unique(*args)
      # need to be shared across child classes as indexes would be common
      class_eval do
        cattr_accessor :_rnu_indexes, :_rnu_error_messages

        _initialize_rnu_attributes
        _indexes = connection.indexes(table_name)
        args.each do |arg|
          _rnu_indexes << _get_index_name(_indexes, arg)
          _rnu_error_messages << Array(arg[:message]).flatten
        end
        prepend InstanceMethods
      end
    end

    private

    def _initialize_rnu_attributes
      self._rnu_indexes = []
      self._rnu_error_messages = []
    end

    def _get_index(_indexes, field)
      _indexes.detect { |index| index.columns.eql?(field) }
    end

    def _get_index_name(_indexes, arg)
      raise ArgumentError, 'field and message must be provided' unless arg.key?(:field) && arg.key?(:message)
      raise 'field should be an array' unless arg[:field].is_a?(Array)

      _index = _get_index(_indexes, arg[:field])
      raise "Couldn't find unique index for field #{arg[:field].join(',')}" unless _index&.unique

      _index.name
    end
  end

  # This module provides instance methods for handling record not unique errors.
  module InstanceMethods
    # handle update_column for rails3, update_columns for rails4+
    if ActiveRecord::VERSION::MAJOR < 4
      def update_column(name, value)
        handle_custom_unique_constraint do
          super(name, value)
        end
      end
    else
      def update_columns(attributes)
        handle_custom_unique_constraint do
          super(attributes)
        end
      end
    end

    if ActiveRecord::VERSION::MAJOR >= 6
      def save(**options, &block)
        handle_custom_unique_constraint do
          super
        end
      end
    elsif ActiveRecord::VERSION::MAJOR >= 5
      def save(*args, &block)
        handle_custom_unique_constraint do
          super
        end
      end
    else
      def save(*)
        handle_custom_unique_constraint do
          super
        end
      end
    end

    private

    def handle_custom_unique_constraint
      yield
    rescue ActiveRecord::RecordNotUnique => e
      _rnu_indexes.each_with_index do |index_name, i|
        next unless e.message.include?(index_name)

        custom_error = self.class._rnu_error_messages[i]
        object = custom_error.last
        custom_error_msg = object.is_a?(Proc) ? object.call(self) : object

        errors.add(custom_error.first, custom_error_msg)
      end
      false
    end
  end
end

ActiveRecord::Base.extend(RecordNotUnique::ClassMethods)
