module LocalMethodCallbacks
  
  Environment = Struct.new(
    :callback,
    :decorated,
    :base_method, # can be UnboundMethod
    :class,
    :receiver,
    :method_arguments,
    :method_block,
    :return_value, # only in after_callback
  ) do

    # returns instance of Environment
    # we pass env.with_context to each callback defined by the user
    # therefore we do ret = self.dup
    def with_context(receiver, args, return_value, block)
      ret = self.dup

      ret.receiver = receiver
      ret.method_arguments = args
      ret.return_value = return_value
      ret.method_block = block

      if self.decorated.is_a? UnboundMethod
        ret.decorated = self.decorated.bind(receiver)
      end

      ret
    end

  end

end