# The Callback#body should be a decorated accepting one argument - env of class MethodEnv.
# One can use the env to access scope of a decorated method.
# ATTENTION - UnboundMethod is NOT callable!

require_relative 'method_env'
require_relative 'callback_decoration'

module LocalMethodCallbacks
  class Callback

    TYPES = %i[before around after]

    attr_reader :type, :body

    # ignores decorated if block_given?
    def initialize(type, body = nil)
      raise Error, "uknown type: #{type}" unless TYPES.include?(type)
      @type = type
      
      @body = block_given? ? Proc.new : body # Proc.new captures block - more efficent than &block
      
      VALIDATE_CALLABLE.(@body)
    end

    # decoration will become a method in a given klass
    # unfortunately we can't just return decoration without calling decoration.define_method!
    # - we'd loose the context of the receiver (self)
    # (note that in Python this wouldn't be a problem, because we pass the receiver explicitly
    # as the first argument)
    def decorate_with_me!(decorated, klass, base_method = nil)
      # env is shared by every method call 
      # that's why we pass to the callback env.with_context
      env = MethodEnv.new

      env.callback = self
      env.decorated = decorated # NOTE: could be an instance of UnboundMethod
      env.base_method = base_method || decorated
      env.method_name = env.base_method.name if env.base_method.respond_to?(:name)

      # closure
      my_body = @body

      decoration = case @type
      when :before
        CallbackDecoration.new {|*args, &block|
          env_with_context = env.with_context(self, args, block)
          
          my_body.call(env_with_context)

          env_with_context.decorated_callable.call(*args, &block)
        }
      when :around
        CallbackDecoration.new {|*args, &block| my_body.call env.with_context(self, args, block)}
      when :after
        CallbackDecoration.new {|*args, &block|
          env_with_context = env.with_context(self, args, block)

          env_with_context.method_value = env_with_context.decorated_callable.call(*args, &block)

          my_body.call(env_with_context)

          env_with_context.method_value
        }
      end
      
      return decoration.define_method!(klass, env.base_method.name)
    end

    # If you want self.body to be instance_evaled
    def as_instance_eval(type = self.type)
      self.class.new(type) do |env|
        env.receiver.instance_exec(env, &self.body)
      end
    end

  end
end