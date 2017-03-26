module LocalMethodCallbacks
  
  Environment = Struct.new(
    :callback,
    :method,
    :method_name,
    :receiver,
    :method_arguments,
    :method_block,
  ) do

    # must return self
    def capture_context(receiver, args, block)
      self.receiver = receiver
      self.method_arguments = args
      self.method_block = block

      self
    end

  end

end