require 'set'

module LocalMethodCallbacks
  class Wrapper < Delegator

  	def initialize(object, methods, callbacks, config = OpenStruct.new)
  		@methods = Set.new(methods.map(&:to_sym))
  		@callbacks, @configuration = callbacks, config
  		super(object)

  		yield @configuration if block_given?
  	end

  	def method_missing(method, *args, &block)
  		return super unless @methods.include?(method)

  		# TODO
  	end

  end
end