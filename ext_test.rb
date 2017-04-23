require "bundler/setup"
require "local_method_callbacks"

before_callback = LocalMethodCallbacks::Callback.new(:before) do |env|
  p "#{env.base_method.name} has been called with args: #{env.method_arguments}"
end

around_callback = LocalMethodCallbacks::Callback.new(:around) do |env|
  p "around callback has been called for method: #{env.base_method.name}"
  ret = env.decorated.call(*env.method_arguments, &env.method_block)
  p "around callback is finished with ret: #{ret}"
  ret
end

after_callback = LocalMethodCallbacks::Callback.new(:after) do |env|
  p "#{env.base_method.name} has been called with return value: #{env.return_value}"
end

callback_chain = LocalMethodCallbacks::CallbackChain.new(callbacks: [before_callback, around_callback, after_callback])

s = "314"

callback_chain.with_callbacks(object: s, method_names: [:to_i]) do
  p "s.dup.to_i in block"
  p s.dup.to_i
  p "s.to_i in block"
  p s.to_i
end

p "s.to_i after block"
p s.to_i