module RecordNotUnique
	
	module ClassMethods
		
		def handle_record_not_unique(*args)
			# need to be shared across child classes as indexes would be common
			class_eval do
				cattr_accessor :_rnu_indexes, :_rnu_error_messages
				
				self._rnu_indexes = []
				self._rnu_error_messages = []
				_indexes = connection.indexes(table_name)
				args.each do |arg|
					raise NotImplementedError unless arg.key?(:field) && arg.key?(:message)
					raise 'field should be an array' unless arg[:field].is_a?(Array)
					_index = _indexes.detect { |index| index.columns.eql?(arg[:field]) }
					raise "Couldn't find unique index for field #{arg[:field].join(',')}" if !_index&.unique
					self._rnu_indexes << _index.name
					self._rnu_error_messages << arg[:message].to_a.flatten
				end
				prepend InstanceMethods
			end
		end
		
	end
	
	module InstanceMethods
		# handle update_column for rails3, update_columns for rails4+
		if ActiveRecord::VERSION::MAJOR < 4
			def update_column(name, value)
				handle_custom_unique_constraint {
					super(name, value)
				}
			end
		else
			def update_columns(attributes)
				handle_custom_unique_constraint {
					super(attributes)
				}
			end
		end

		private
		
		case ActiveRecord::VERSION::MAJOR 
		when 6
			def create_or_update(**, &block)
				handle_custom_unique_constraint {
					super
				}
			end
		when 5
			def create_or_update(*args, &block)
				handle_custom_unique_constraint {
					super
				}
			end
		else
			def create_or_update
				handle_custom_unique_constraint {
					super
				}
			end
		end

		def handle_custom_unique_constraint
			begin
				yield
			rescue ActiveRecord::RecordNotUnique => e
				self._rnu_indexes.each_with_index { |index_name, i|
					if e.message.include?(index_name)
						custom_error = self.class._rnu_error_messages[i]
						object = custom_error.last
						custom_error_msg = object.is_a?(Proc) ? object.call : object
						
						self.errors.add(custom_error.first, custom_error_msg)
					end
				}
				false
			end
		end
	end
end

ActiveRecord::Base.extend(RecordNotUnique::ClassMethods)