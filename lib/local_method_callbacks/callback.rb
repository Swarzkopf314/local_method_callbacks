# The Callback#body should be a decorated accepting one argument - env of class Environment.
# One can use the env to access scope of a decorated method.
# ATTENTION - UnboundMethod is NOT callable!

module LocalMethodCallbacks
  class Callback

    TYPES = %i[before around after]
    VALIDATE_CALLABLE = proc do |body|
      raise "no body specified!" if body.nil?
      raise "body should be callable!" unless body.respond_to?(:call)
    end

    attr_reader :type, :body

    class Decoration < Proc
      def decorate_method!(klass, name)
        klass.send(:define_method, name, self)
        
        return klass.instance_method(name)
      end
    end

    # ignores decorated if block_given?
    def initialize(type, body = nil)
      raise "uknown type: #{type}" unless TYPES.include?(type)
      @type = type
      
      @body = block_given? ? Proc.new : body # Proc.new captures block - more efficent than &block
      
      VALIDATE_CALLABLE.(@body)
    end

    # decoration will become a method in a given klass
    # unfortunately we can't just return decoration without calling decoration.decorate_method!
    # - we'd loose the context of the receiver (self)
    # (note that in Python this wouldn't be a problem, because we pass the receiver explicitly
    # as the first argument)
    def decorate_with_me!(decorated, klass, base_method = nil)
      # env is shared by every method call 
      # that's why we pass to the callback env.with_context
      env = Environment.new

      env.callback = self
      env.decorated = decorated # NOTE: could be an instance of UnboundMethod
      env.base_method = base_method || decorated
      env.class = klass

      # closure
      my_body = @body

      decoration = case @type
      when :before
        Decoration.new {|*args, &block|
          env_with_context = env.with_context(self, args, nil, block)
          
          my_body.call(env_with_context)

          env_with_context.decorated.call(*args, &block)
        }
      when :around
        Decoration.new {|*args, &block| my_body.call env.with_context(self, args, nil, block)}
      when :after
        Decoration.new {|*args, &block|
          env_with_context = env.with_context(self, args, nil, block)

          env_with_context.return_value = env_with_context.decorated.call(*args, &block)

          my_body.call env_with_context

          env_with_context.return_value
        }
      end
      
      return decoration.decorate_method!(env.class, env.base_method.name)
    end

    # If you want self.body to be instance_evaled
    def as_instance_eval(type = self.type)
      self.class.new(type) do |env|
        env.receiver.instance_exec(env, &self.body)
      end
    end

  end
end