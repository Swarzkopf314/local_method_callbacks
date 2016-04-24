module LocalMethodCallbacks
  class Callbacks
  	include Configuration
  	extend HasCollections

  	KINDS = %i[before around after]

  	has_collections Array, *KINDS

  	alias_method :callbacks, :my_collections

  	def initialize(callbacks = {}, config = nil)
  		_merge(callbacks)

  		set_configuration(config) # set it during creation
  		yield(configuration) if block_given?
	 	end

	 	# override
	 	def default_configuration
	 		LocalMethodCallbacks.configuration
	 	end

 		def with_callbacks_for(object, *methods, &block)
 			# TODO
		end

		def wrap_with_callbacks(object, methods)
			Wrapper.new(object, methods, callbacks, configuration)
			# TODO
		end

		def merge(other_callbacks)
			_merge(other_callbacks.callbacks)
		end

		private

			def _merge(hash)
				KINDS.each do |kind|
					callbacks[kind] |= hash[kind]
				end
			end

  end
end