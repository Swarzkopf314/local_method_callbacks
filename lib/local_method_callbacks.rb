require "local_method_callbacks/version"
require "local_method_callbacks/callback"
require "local_method_callbacks/callback_chain"
require "local_method_callbacks/environment"

module LocalMethodCallbacks

	def self.curry_callbacks(callbacks, &block)
		Callbacks.new(callbacks, &block)
	end 

	# conveniece method to be included in object's class
	def with_callbacks_for(methods, callbacks, &block)
		LocalMethodCallbacks.with_callbacks_for(self, methods, callbacks, &block)
	end

	def self.with_callbacks_for(object, methods, callbacks, &block)
		curry_callbacks(callbacks).with_callbacks_for(object, methods, &block)
	end

 	## Wrapper

	# conveniece method to be included in object's class
	def wrap_with_callbacks(methods, callbacks)
		LocalMethodCallbacks.wrap_with_callbacks(self, methods, callbacks)
	end

	def self.wrap_with_callbacks(object, methods, callbacks)
		curry_callbacks(callbacks).wrap_with_callbacks(object, methods)
	end

end
