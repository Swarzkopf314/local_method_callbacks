require "local_method_callbacks/version"
require "local_method_callbacks/callback"
require "local_method_callbacks/callback_chain"
require "local_method_callbacks/error"
require "local_method_callbacks/environment"
require "local_method_callbacks/wrapper"

module LocalMethodCallbacks

  VALIDATE_CALLABLE = proc do |body|
    raise Error, "no body specified!" if body.nil?
    raise Error, "body should be callable!" unless body.respond_to?(:call)
  end

	def self.make_callback(type, body = nil, &block)
		Callback.new(type, body, &block)
	end

	def self.curry_callbacks(opts = {})
		CallbackChain.new(opts)
	end 

	def self.wrap_with_callbacks(object, opts = {})
		curry_callbacks(opts).wrap_with_callbacks(object)
	end

	# if this gem fails somehow, raise LocalMethodCallbacks::Error
	def self.with_internal_exceptions
		yield
	rescue Exception => e
		raise Error, e.message, caller[1..-1]
	end

end
