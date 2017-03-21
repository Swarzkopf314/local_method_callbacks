module LocalMethodCallbacks
  class Callback

    KINDS = %i[before around after]

    attr_reader :kind, :body

    def initialize(kind, &block)
      raise "uknown kind: #{kind}" unless KINDS.include?(kind)
      raise "no block given!" unless block_given?

      @kind = kind
      @body = block
    end

    # returns callable decorated with self.body
    def decorate(callable)
      env = Environment.new

      env.callback = self
      env.method = callable
      env.method_name = callable.name if callable.respond_to?(:name)

      decorated = case @kind
      when :before
        proc {|*args| 
          @body.call env.capture_context(self, args)
          method.call(*args)
        }
      when :around
        proc {|*args| @body.call env.capture_context(self, args)}
      when :after
        proc {|*args| 
          method.call(*args)
          @body.call env.capture_context(self, args)
        }
      end

      return decorated
    end

  end
end