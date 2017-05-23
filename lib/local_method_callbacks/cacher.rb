# with_instance_eval + instance variables
require_relative 'callback_decoration'

module LocalMethodCallbacks
	class Cacher < Callback

    Store = Struct.new(
      :was_cached,
      :value,
    )

    def generate_cache_key(receiver, method_name)
      "#{receiver.object_id}_#{method_name}"
    end

    # cache_store expires with this object, so no worries about GC
    def initialize(cache_store = {})
      
      body = proc do |env|
        store = (cache_store[generate_cache_key(env.receiver, env.method_name)] ||= Store.new(false, nil))
        
        if store[:was_cached]
          store[:value]
        else
          store[:value] = env.decorated_callable.(*env.method_arguments, &env.method_block)
          store[:was_cached] = true
          store[:value]
        end
      end

      super(:around, body)
    end

	end
end