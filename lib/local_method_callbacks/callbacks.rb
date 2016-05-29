module LocalMethodCallbacks
  class Callbacks
  	include Configuration
  	extend HasCollections

  	KINDS = %i[before around after]

  	has_collections Array, *KINDS

  	alias_method :callbacks, :my_collections

  	def initialize(_callbacks = {})
  		hmerge(_callbacks)

  		set_configuration(default_configuration) # set it during creation
  		yield(configuration) if block_given?
	 	end

	 	# override
	 	def default_configuration
	 		LocalMethodCallbacks.configuration.dup
	 	end

 		def with_callbacks_for(object, *methods, &block)
 			methods = methods.flatten
 			singleton = object.singleton_class
 			
 			method_hash = methods.inject({}) do |memo, name| 
 				original = object.method(name)
 				memo[name] = {original: object.method(name), singleton: original.owner == singleton_class}
 				memo
 			end 

 			method_hash.each do |name, h|
 				object.define_singleton_method(name) do |*args|

 					h[:original].call(*args)

 				end
 			end

 		ensure
 			method_hash.each do |name, h|
 				if h[:singleton]
 					object.define_singleton_method(name, h[:original])
 				else
 					singleton.remove_method(name)
 				end
 			end
		end

		def wrap_with_callbacks(object, *methods)
			Wrapper.new(object, methods.flatten, callbacks, configuration)
			# TODO
		end

		def merge(other_callbacks)
			hmerge(other_callbacks.callbacks)
		end

		def hmerge(hash)
			KINDS.each do |kind|
				add_callbacks(kind, hash[kind])
			end
		end

		def add_callbacks(kind = :before, *callbacks)
			callbacks[kind] |= callbacks.flatten
		end

		private


  end
end