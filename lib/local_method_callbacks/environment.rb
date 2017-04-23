module LocalMethodCallbacks
  
  Environment = Struct.new(
    :callback,
    :decorated,
    :base_method,
    :receiver,
    :method_arguments,
    :method_block,
  ) do

    # returns self
    def with_context(receiver, args, block)
      self.receiver = receiver
      self.method_arguments = args
      self.method_block = block

      self
    end

  end

end