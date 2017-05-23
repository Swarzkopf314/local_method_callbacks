require_relative "wrapper"
require_relative "callback_decoration"

module LocalMethodCallbacks
  class CallbackChain

  	# TODO - ban these
  	# BANNED_METHOD_NAMES = [:method]

  	# to cache some options (:objects, :classes, :callbacks, :method_names)
  	attr_reader :default_opts 

  	# default_opts: 
  	# objects - list of objects whose methods are to be redefined
  	# classes - list of classes whose methods are to be redefined
  	# callbacks - list of callbacks LocalMethodCallbacks::Callback
  	# method_names - list of methods (method names) to be redefined
  	def initialize(opts = {})
  		@default_opts = opts.dup
  		@default_opts.default_proc = proc {|this, key| this[key] = []}
	 	end

		def wrap_with_callbacks(object)
			Wrapper.new(object, self)
		end

    def wrap_method_with_callbacks(method, klass, callbacks = @default_opts[:callbacks])
      if method.owner != klass
        # this allows the method to be sensitive to changes in the original method
        method = CallbackDecoration.define_placeholder!(klass, method.name)
      end

      callbacks.inject(method) do |acc, callback|
        callback.decorate_with_me!(acc, klass, method)
      end
    end

    def revert_to_method(old_method, klass)
      if old_method.owner != klass 
        klass.send(:remove_method, old_method.name)
      else
        klass.send(:define_method, old_method.name, old_method)
      end
    end

 		def with_callbacks(opts = {}, &block)
			opts = @default_opts.merge(opts) # preserves default_proc

      saturate_opts!(opts)

 			__with_callbacks__(opts, &block)
 		end

    private

  		# we avoid using alias to allow nesting calls to #with_callbacks (otherwise there is a loop)
  		# we use block and closures to avoid problem with garbage collecting
  		# and memory leaks (because bound methods point to the objects)
  		# - it's easy to clean everyting up

      # NOTE - if we redefine the method in the original klass,
      # the temporary method defined here won't see the change - 
      # because it delegates to the original one stored in closure (see Callback#decorate_with_me!) 
  		def __with_callbacks__(opts = {})
        methods_hash = new_methods_hash

  			LocalMethodCallbacks.with_internal_exceptions do
          __setup__(methods_hash, opts)
  			end

  			begin
  				yield
  			ensure
  				LocalMethodCallbacks.with_internal_exceptions do
            __cleanup__(methods_hash)
  				end
  			end # ensure
  		end
      
      def __setup__(methods_hash, opts)
        # instance_method is a class-level method returning instance-level method, so it's ok
        opts[:classes].each do |klass| # .hmap {|klass| {klass => opts[:method_names].map ... }}
          methods_hash[klass] = opts[:method_names].map {|method_name| klass.instance_method(method_name)}
          # methods = opts[:method_names].map {|method_name| opts[:object].method(method_name)}
        end
        
        methods_hash.each do |klass, methods|
          methods.each do |method|
            wrap_method_with_callbacks(method, klass, opts[:callbacks])
          end
        end
      end

      def __cleanup__(methods_hash)
        methods_hash.each do |klass, old_methods|
          old_methods.each {|old_method| revert_to_method(old_method, klass)}
        end
      end

      def new_methods_hash
        Hash.new {|this, klass| this[klass] = []}
      end

      # def methods_hash
      #   @lava ||= Hash.new {|this, klass| this[klass] = []}
      # end

      def saturate_opts!(opts)
        # first redefine methods in classes, then in objects
        # avoid calling obj.singleton_class (in case smbdy wants to override it with this gem)
        opts[:classes] |= opts[:objects].map {|obj| class << obj; self end}
      end

  end
end
