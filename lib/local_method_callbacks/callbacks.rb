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
 			@object = object
 			methods = methods.flatten
 			singleton = object.singleton_class
 			
 			method_hash = methods.inject({}) do |memo, name| 
 				original = object.method(name)
 				memo[name] = {original: object.method(name), singleton: original.owner == singleton_class, name: name}
 				memo
 			end 

 			method_hash.each do |name, h|
 				object.define_singleton_method(name) do |*args|
 					method_with_callbacks(h, args)
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

 			@object = nil
		end

		def wrap_with_callbacks(object, *methods)
			yield Wrapper.new(object, methods.flatten, callbacks, configuration)
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

			def method_with_callbacks(h, args)
				if callbacks[:around].any?
					ret = callbacks[:around].each {|c| call_callback(c, h, args.unshift(h[:original]))}
				else
					callbacks[:before].each {|c| call_callback(c, h, args)}

					ret = h[:original].call(*args)

					callbacks[:after].each {|c| call_callback(c, h, args)}
				end

				ret
			end

			def call_callback(c, h, args)
				if configuration.instance_eval
					@object.instance_exec(adjust_args(h, args), c)
				else
					c.call(adjust_args(h, args))
				end
			end

			def adjust_args(h, args)
				args.unshift(@object) if configuration.pass_receiver
				args.unshift(h[:name]) if configuration.pass_method_name
				args
			end

  end
end