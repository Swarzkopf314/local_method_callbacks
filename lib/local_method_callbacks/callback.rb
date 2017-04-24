# The Callback#body should be a decorated accepting one argument - env of class Environment.
# One can use the env to access scope of a decorated method.
# ATTENTION - UnboundMethod is NOT callable!

module LocalMethodCallbacks
  class Callback

    TYPES = %i[before around after]

    attr_reader :type, :body

    class Decoration < Proc; end

    # ignores decorated if block_given?
    def initialize(type, body = nil)
      raise "uknown type: #{type}" unless TYPES.include?(type)
      @type = type
      
      @body = block_given? ? Proc.new : body # Proc.new captures block - more efficent than &block
      
      raise "no body specified!" if @body.nil?
      raise "second argument should be callable!" unless @body.respond_to?(:call)
    end

    def decorate_class_method_with_me(decorated, base_method = decorated, klass)
      # TODO
      # instead of returning Decoration.new, we do klass.send(:define_method)
      # we can't use decorate_with_me
    end

    # returns decorated decorated with self.body
    # we assume it will be used in definition of a method,
    # in particular it will be instance_eval-ed
    # decoration will become a method in a given klass
    def decorate_with_me!(decorated, klass, base_method = nil)
      # env is shared by every method call 
      # that's why we pass env.with_context to the callback
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

      env.class.send(:define_method, env.base_method.name, decoration)
      decoration = env.class.instance_method(env.base_method.name)

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