module LocalMethodCallbacks
  class Callbacks
  	include Configuration
  	extend HasCollections

  	KINDS = %i[before_callbacks around_callbacks after_callbacks]

  	has_collections Array, *KINDS

  	def initialize(callbacks = {})
  		_merge(callbacks)

  		yield(configuration) if block_given?
	 	end

	 	def default_configuration
	 		LocalMethodCallbacks.configuration
	 	end

 		def with_callbacks_for(object, *methods, &block)

		end

		def merge(other_callbacks)
			_merge(other_callbacks.my_collections)
		end

		private

			def _merge(hash)
				KINDS.each do |kind|
					my_collections[kind] |= hash[kind]
				end
			end

  end
end