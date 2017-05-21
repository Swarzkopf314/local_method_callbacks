require "bundler/setup"
require "local_method_callbacks"

before_callback = LocalMethodCallbacks.make_callback(:before) do |env|
  p "#{env.base_method.name} has been called with args: #{env.method_arguments}"
  p "RECEIVER: #{env.receiver}"
end

around_callback = LocalMethodCallbacks.make_callback(:around) do |env|
  p "around callback has been called for method: #{env.base_method.name}"
  ret = env.decorated_callable.call(*env.method_arguments, &env.method_block)
  p "around callback is finished with ret: #{ret}"
  ret
end

after_callback = LocalMethodCallbacks.make_callback(:after) do |env|
  p "#{env.base_method.name} has been called with return value: #{env.method_value}"
  p "RECEIVER: #{env.receiver}"
end

callback_chain = LocalMethodCallbacks.curry_callbacks(callbacks: [before_callback, around_callback, after_callback])

s = "314"
x = "108"

callback_chain.with_callbacks(objects: [s], method_names: [:to_i]) do
  p "s.dup.to_i in block"
  p s.dup.to_i
  p "s.to_i in block"
  p s.to_i

  p "x.to_i in block"
  p x.to_i

  callback_chain.with_callbacks(classes: [String], method_names: [:to_i]) do
    p "s.to_i in first nested block, shouldn't see any difference"
    p s.to_i
  end

  callback_chain.with_callbacks(objects: [s, x], classes: [String], method_names: [:to_i]) do
    p "s.to_i in nested block"
    p s.to_i

    p "x.to_i in nested block"
    p x.to_i
  end
end

p "s.to_i after block"
p s.to_i

p "x.to_i after block"
p x.to_i