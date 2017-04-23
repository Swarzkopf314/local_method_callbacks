# The Callback#body should be a callable accepting one argument - env of class Environment.
# One can use the env to access scope of a decorated method.
# ATTENTION - UnboundMethod is NOT callable!

module LocalMethodCallbacks
  class Callback

    TYPES = %i[before around after]

    attr_reader :type, :body

    # ignores callable if block_given?
    def initialize(type, callable = nil)
      raise "uknown type: #{type}" unless TYPES.include?(type)
      @type = type
      
      @body = block_given? ? Proc.new : callable # Proc.new captures block - more efficent than &block
      
      raise "no body specified!" if @body.nil?
      raise "second argument should be callable!" unless @body.respond_to?(:call)
    end

    # returns callable decorated with self.body
    # we assume it will be used in definition of a method,
    # in particular it will be instance_eval-ed
    def decorate_with_me(callable, base_method = callable)
      env = Environment.new

      env.callback = self
      env.decorated = callable
      env.base_method = base_method

      # closure
      my_body = @body

      decoration = case @type
      when :before
        proc {|*args, &block| 
          my_body.call env.with_context(self, args, nil, block)
          callable.call(*args, &block)
        }
      when :around
        proc {|*args, &block| my_body.call env.with_context(self, args, nil, block)}
      when :after
        proc {|*args, &block| 
          return_value = callable.call(*args, &block)
          my_body.call env.with_context(self, args, return_value, block)
          return_value
        }
      end

      return decoration
    end

    # If you want self.body to be instance_evaled
    def as_instance_eval(type = self.type)
      self.class.new(type) do |env|
        env.receiver.instance_exec(env, &self.body)
      end
    end

  end
end