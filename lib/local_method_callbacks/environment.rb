module LocalMethodCallbacks
  
  Environment = Struct.new(
    :callback,
    :method,
    :method_name,
    :receiver,
    :method_arguments,
  ) do

    def capture_context(receiver, args)
      self.receiver = receiver
      self.method_arguments = args
      self
    end

  end

end