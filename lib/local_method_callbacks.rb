require "local_method_callbacks/version"
require "local_method_callbacks/configuration"

module LocalMethodCallbacks
	extend Configuration

	# override
	def self.default_configuration
		super.tap do |config|
			config.pass_receiver = false
			config.pass_method_name = false
		end
	end

	def self.curry_callbacks(callbacks, configuration = self.configuration, &block)
		Callbacks.new(callbacks, configuration, &block)
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
