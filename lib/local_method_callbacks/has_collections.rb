module LocalMethodCallbacks
	module HasCollections

		def has_collections(klass, *names)
			module_eval(<<-RUBY) unless method_defined? :my_collections
				def my_collections
					return @my_collections unless @my_collections.nil?
					
					@my_collections = Hash.new do |this, key|
							config = self.class.__has_collections_config__
							this[key] = config[key].new if config.has_key? key
						end.tap do |h|
							def h.[]=(key, val)
								klass = self.class.__has_collections_config__[key]
								raise "Wrong collection!" if klass && !val.is_a? klass
								super
							end
					end
				end	
			RUBY

			names.each do |name|
				__has_collections_config__[name] = klass

				define_method("#{name}=") do |collection|
					raise "Wrong collection!" unless collection.is_a? self.class.__has_collections_config__[name]
					my_collections[name] = collection
				end

				define_method(name) do
					my_collections[name] ||= self.class.__has_collections_config__[name].new
				end
			end
		end

		def __has_collections_config__
			@__has_collections_config__ ||= {}
		end

	end
end