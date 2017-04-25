module LocalMethodCallbacks
  class CallbackChain

  	# TODO - ban these
  	# BANNED_METHOD_NAMES = [:method]

  	attr_reader :callbacks,
  	 :default_opts # to cache some options (:object, :class, :callbacks, :method_names)

  	# default_opts: 
  	# object - object whose methods are redefined
  	# class - class whose methods are redefined
  	# callbacks - list of callbacks LocalMethodCallbacks::Callback
  	# method_names - list of methods (names) to be redefined
  	def initialize(opts = {})
  		@default_opts = opts.dup
  		@default_opts[:callbacks] ||= []
  		@default_opts[:method_names] ||= []
	 	end

 		def with_callbacks(opts = {}, &block)
 			if opts.has_key?(:object)
 				# avoid calling opts[:object].singleton_class (in case smbdy wants to override it with this gem)
 				singleton_klass = class << opts[:object]; self end
 				# avoid changing the passed hash
 				opts = opts.merge(:class => singleton_klass)
 			end

 			__with_callbacks__(opts, &block)
 		end

		# TODO
		def wrap_with_callbacks(object, *methods)
			Wrapper.new(object, methods.flatten, callbacks, configuration)
		end

		# we avoid using alias to allow nesting calls to #with_callbacks (otherwise there is a loop)
		# we use block and closures to avoid problem with garbage collecting
		# and memory leaks (because bound methods point to the objects)
		def __with_callbacks__(opts = {}, &block)
			opts = @default_opts.merge(opts)

			# instance_method is a class-level method returning instance-level method, so it's ok
			methods = opts[:method_names].map {|method_name| opts[:class].instance_method(method_name)}
			# methods = opts[:method_names].map {|method_name| opts[:object].method(method_name)}
			
			begin
				methods.map do |method|
					opts[:callbacks].inject(method) do |acc, callback|
						callback.decorate_with_me!(acc, opts[:class], method)
					end
				end

				yield
			else
				# cleanup
				methods.each do |old_method|
					if old_method.owner == opts[:class] 
						opts[:class].send(:define_method, old_method.name, old_method)
					else
						opts[:class].send(:remove_method, old_method.name)
					end
				end
			end
		end
		private :__with_callbacks__

  end
end
