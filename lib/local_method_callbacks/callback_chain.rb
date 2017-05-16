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

 		def with_callbacks(opts = {}, &block)
			opts = @default_opts.merge(opts) # preserves default_proc

			# first redefine methods in classes, then in objects
			# avoid calling obj.singleton_class (in case smbdy wants to override it with this gem)
 			opts[:classes] |= opts[:objects].map {|obj| class << obj; self end}

 			__with_callbacks__(opts, &block)
 		end

		# we avoid using alias to allow nesting calls to #with_callbacks (otherwise there is a loop)
		# we use block and closures to avoid problem with garbage collecting
		# and memory leaks (because bound methods point to the objects)
		# - it's easy to clean everyting up

    # NOTE - if we redefine the method in the original klass,
    # the temporary method defined here won't see the change - 
    # because it delegates to the original one stored in closure (see Callback#decorate_with_me!) 
		def __with_callbacks__(opts = {}, &block)
			methods_hash = Hash.new {|this, klass| this[klass] = []}

			LocalMethodCallbacks.with_internal_exceptions do
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
			end # with_internal_exceptions

			begin
				yield
			ensure
				# cleanup
				LocalMethodCallbacks.with_internal_exceptions do
					methods_hash.each do |klass, old_methods|
						old_methods.each {|old_method| revert_method(old_method, klass)}
					end
				end # with_internal_exceptions

			end # ensure
		end
		private :__with_callbacks__

		def wrap_method_with_callbacks(method, klass, callbacks = @default_opts[:callbacks])
			if method.owner != klass
				# this allows the method to be sensitive to changes in the original method
				method = Callback::Decoration.define_placeholder!(klass, method.name)
			end

			callbacks.inject(method) do |acc, callback|
				callback.decorate_with_me!(acc, klass, method)
			end
		end

		def revert_method(old_method, klass)
			if old_method.owner != klass 
				klass.send(:remove_method, old_method.name)
			else
				klass.send(:define_method, old_method.name, old_method)
			end
		end

  end
end
