module LocalMethodCallbacks
	module HasCollections

		def has_collections(klass, *names)
			module_eval <<-RUBY
				def my_collections
					@my_collections ||= {}
				end
			RUBY

			names.each do |name|
				define_method("#{name}=") do |collection|
					my_collections[name] = collection
				end

				define_method(name) do
					my_collections[name] ||= klass.new
				end
			end
		end

	end
end