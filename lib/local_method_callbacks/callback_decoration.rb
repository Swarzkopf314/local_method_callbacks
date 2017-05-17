    
module LocalMethodCallbacks
  class Callback

    class Decoration < Proc
      
      def define_method!(klass, name)
        klass.send(:define_method, name, self)
        
        return klass.instance_method(name)
      end

      # just calls super, this allows the method to be held in closure and still be sensitive to changes 
      # in the original method
      def self.define_placeholder!(klass, name)
        placeholder = self.new {|*args, &block| super(*args, &block)}

        placeholder.define_method!(klass, name)
      end
      
    end # Decoration

  end
end