
module LocalMethodCallbacks
  class Wrapper < Delegator

  	def initialize(object, callback_chain)
      singleton = class << self; self end

      methods = callback_chain.default_opts[:method_names].map do |name|
        Callback::Decoration.define_placeholder!(singleton, name)
      end

      methods.each do |method|
        callback_chain.wrap_method_with_callbacks(method, singleton)
      end

      super(object)
  	end

  end
end