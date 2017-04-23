module LocalMethodCallbacks
  
  Environment = Struct.new(
    :callback,
    :decorated,
    :base_method,
    :receiver,
    :method_arguments,
    :method_block,
    :return_value, # only in after_callback
  ) do

    # returns self
    def with_context(receiver, args, return_value, block)
      self.receiver = receiver
      # self.base_method = self.base_method.bind(receiver)
      self.method_arguments = args
      self.method_block = block
      self.return_value = return_value

      self
    end

  end

end