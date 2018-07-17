module RecordNotUnique
	
	def self.included(klass)
		klass.extend ClassMethods
	end
	
	module ClassMethods
		
		def handle_record_not_unique(*args)
			# need to be shared across child classes as indexes would be common
			class_eval do
				cattr_accessor :_rnu_indexes, :_rnu_error_messages
				self._rnu_indexes = []
				self._rnu_error_messages = []
				args.each do |arg|
					raise NotImplementedError unless arg.key?(:index) && arg.key?(:message)
					self._rnu_indexes << arg[:index]
					self._rnu_error_messages << arg[:message].to_a.flatten
				end
				prepend InstanceMethods
			end
		end
		
	end
	
	module InstanceMethods
		# revisit kind of saves for higher versions
		def save(*)
			handle_custom_unique_constraint {
				super
			}
		end
	
		# handle update_column for rails3, update_columns for rails4+
		if ActiveRecord::VERSION::STRING.to_i < 4
			def update_column(name, value)
				handle_custom_unique_constraint {
					super(name, value)
				}
			end
		else
			def update_columns(attributes)
				handle_custom_unique_constraint {
					super(name, value)
				}
			end
		end

		private

		def handle_custom_unique_constraint
			begin
				yield
			rescue ActiveRecord::RecordNotUnique => e
				self.class._rnu_indexes.each_with_index { |index_name, i|
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

ActiveRecord::Base.send(:include, RecordNotUnique)