module RecordNotUnique
	
	def self.included(klass)
		klass.extend ClassMethods
	end
	
	module ClassMethods
		
		def handle_record_not_unique(args)
			if args.instance_of?(Hash)
				raise NotImplementedError unless args.key?(:index) && args.key?(:message)
				@indexes = [args[:index]]
				@error_messages = args[:message].to_a
			elsif args.instance_of?(Array)
				@indexes = []
				@error_messages = []
				args.each { |arg|
					raise NotImplementedError unless arg.key?(:index) && arg.key?(:message)
					@indexes << arg[:index]
					@error_messages << arg[:message].to_a.flatten
				}
			end
		
			class << self
				attr_accessor :indexes, :error_messages
			end
			prepend InstanceMethods
		end
		
	end

	module InstanceMethods
		# revisit kind of saves for higher versions
		def save(*)
			handle_custom_unique_constraint {
				super
			}
		end

		# might need to add support update_columns/update when moving to rails 4+
		def update_column(name, value)
			handle_custom_unique_constraint {
				super(name, value)
			}
		end

		private

		def handle_custom_unique_constraint
			begin
				yield
			rescue ActiveRecord::RecordNotUnique => e
				self.class.indexes.each_with_index { |index_name, i|
					if e.message.include?(index_name)
						custom_error = self.class.error_messages[i]
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