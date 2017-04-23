module LocalMethodCallbacks
  class CallbackChain

  	attr_reader :callbacks

  	# defaults: 
  	# object - object whose methods are redefined
  	# class - class whose methods are redefined
  	# callbacks - list of callbacks LocalMethodCallbacks::Callback
  	# methods - list of methods to be redefined
  	def initialize(opts = {})
  		@default_opts = opts.dup
  		@default_opts[:callbacks] ||= []
  		@default_opts[:method_names] ||= []
	 	end

		# we avoid using alias to allow nesting these (otherwise there is a loop)
		# we could curry that object via register_object etc.
		# we could also register callbacks to object - and trust the programmer to later unregister it (or not)
		# but it forces us to keep track of all the methods in order to make it possible to unregister it
		# and there would be a problem with garbage collecting - memory leaks (because bound methods point to the objects)
		# - add with_class_callbacks_for - work same as with singleton_class
		# so instance with_callbacks_for should delegate to with_class_callbacks_for
 		def with_callbacks(opts = {}, &block)
 			if opts.has_key?(:object)
 				# avoid changing the passed hash
 				opts = opts.merge(:class => opts[:object].singleton_class)
 			end

 			with_class_callbacks(opts, &block)
 		end

 		# if no block is given, returns proc that accepts proc and calls it with decoration
		def with_class_callbacks(opts = {}, &block)
			opts = @default_opts.merge(opts)

			# methods = opts[:method_names].map {|method_name| opts[:class].instance_method(method_name)}
			methods = opts[:method_names].map {|method_name| opts[:object].method(method_name)}
			
			new_method_bodies = methods.map do |method|
				opts[:callbacks].inject(method) do |acc, callback|
					callback.decorate_with_me(acc, method)
				end
			end

			ret = proc do |decorated_proc|
				
				begin
					opts[:method_names].zip(new_method_bodies).each do |name, new_method_body|
						opts[:class].send(:define_method, name, new_method_body)
					end

					decorated_proc.call()
				ensure
					# cleanup
					methods.each do |old_method|
						if old_method.owner == opts[:class] 
							opts[:class].define_method(old_method.name, old_method)
						else
							opts[:class].send(:remove_method, old_method.name)
						end
					end
				end
			end

			if block.nil?
				return ret
			else
				ret.call(block)
			end

		end

		# TODO
		def wrap_with_callbacks(object, *methods)
			yield Wrapper.new(object, methods.flatten, callbacks, configuration)
		end

  end
end
