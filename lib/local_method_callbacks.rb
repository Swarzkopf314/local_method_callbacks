require "local_method_callbacks/version"
require "local_method_callbacks/callback"
require "local_method_callbacks/callback_chain"
require "local_method_callbacks/error"

require "local_method_callbacks/cacher"

module LocalMethodCallbacks

  VALIDATE_CALLABLE = proc do |body|
    raise Error, "no body specified!" if body.nil?
    raise Error, "body should be callable!" unless body.respond_to?(:call)
  end

	def self.make_callback(type, body = nil, &block)
		Callback.new(type, body, &block)
	end

	def self.callback_chain(opts = {})
		CallbackChain.new(opts)
	end

	def self.caching_callback_chain(opts = {})
		opts[:callbacks] = [Cacher.new]
		callback_chain(opts)
	end
	
	# def self.with_callbacks(opts = {}, &block)
	# 	callback_chain(opts).with_callbacks(&block)
	# end

	# def self.wrap_with_callbacks(object, opts = {})
	# 	callback_chain(opts).wrap_with_callbacks(object)
	# end

	# if this gem fails somehow, raise LocalMethodCallbacks::Error
	def self.with_internal_exceptions
		yield
	rescue Exception => e
		raise Error, e.message, caller[1..-1]
	end

end
