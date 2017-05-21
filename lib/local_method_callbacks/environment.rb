module LocalMethodCallbacks
  
  Environment = Struct.new(
    :callback,
    :receiver,
    :decorated,
    :decorated_callable,
    :base_method, # can be UnboundMethod
    :method_name,
    :method_arguments,
    :method_block,
    :method_value, # only in after_callback
  ) do

    # returns instance of Environment
    # we pass env.with_context to each callback defined by the user
    # therefore we do ret = self.dup to avoid user-caused bugs
    def with_context(receiver, args, block)
      ret = self.dup # see comments above

      ret.receiver = receiver
      ret.method_arguments = args
      ret.method_value = method_value
      ret.method_block = block
      ret.decorated_callable = ret.decorated

      if ret.decorated_callable.is_a? UnboundMethod
        ret.decorated_callable = ret.decorated_callable.bind(receiver)
      end

      VALIDATE_CALLABLE.(ret.decorated_callable)

      ret
    end

  end

end