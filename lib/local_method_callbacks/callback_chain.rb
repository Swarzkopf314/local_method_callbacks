module LocalMethodCallbacks
  class CallbackChain

  	attr_reader :callbacks

  	def initialize(callbacks = [])
  		@callbacks = callbacks
	 	end

		# we avoid using alias to allow nesting these (otherwise there is a loop)
		# we could curry that object via register_object etc.
		# we could also register callbacks to object - and trust the programmer to later unregister it (or not)
		# but it forces us to keep track of all the methods in order to make it possible to unregister it
		# and there would be a problem with garbage collecting - memory leaks (because bound methods point to the objects)
		# - add with_class_callbacks_for - work same as with singleton_class
		# so instance with_callbacks_for should delegate to with_class_callbacks_for
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

  end
end
