# The Callback#body should be a callable accepting one argument - env of class Environment.
# One can use the env to access scope of a decorated method.

module LocalMethodCallbacks
  class Callback

    KINDS = %i[before around after]

    attr_reader :type, :body

    # ignores callable if block_given?
    def initialize(type, callable = nil)
      raise "uknown type: #{type}" unless KINDS.include?(type)
      @type = type
      
      @body = block_given? ? Proc.new : callable # Proc.new captures block - more efficent than &block
      
      raise "no body specified!" if @body.nil?
      raise "second argument should be callable!" unless @body.repspond_to?(:call)
    end

    # returns callable decorated with self.body
    def decorate(callable)
      env = Environment.new

      env.callback = self
      env.method = callable
      env.method_name = callable.name if callable.respond_to?(:name)

      body = @body

      decoration = case @type
      when :before
        proc {|*args, &block| 
          body.call env.capture_context(self, args, block)
          method.call(*args, &block)
        }
      when :around
        proc {|*args, &block| body.call env.capture_context(self, args, block)}
      when :after
        proc {|*args, &block| 
          method.call(*args, &block)
          body.call env.capture_context(self, args, &block)
        }
      end

      return decoration
    end

    # If you want some callback instance_evaled
    def as_instance_eval(type = self.type)
      self.class.new(type) do |env|
        env.receiver.instance_exec(env, &self.body)
      end
    end

  end
end