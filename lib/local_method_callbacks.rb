require "local_method_callbacks/version"
require "local_method_callbacks/configuration"

module LocalMethodCallbacks
  extend Configuration

  def default_configuration
  	super.tap do |config|
  		config.pass_receiver = false
  		config.pass_method_name = false
  	end
  end

  def with_callbacks_for(*methods, &block)

  end

	def self.with_callbacks_for(object, methods, callbacks, &block)
		callbacks = Callbacks.new(callbacks)
		callbacks.with_callbacks_for(object )


	end

	def curry_callbacks(callbacks)
		Callbacks.new(callbacks)
	end 

end
