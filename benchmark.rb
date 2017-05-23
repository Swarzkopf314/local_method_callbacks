# test performance of nesting procs vs calling them sequentially
# nesting the callbacks has better performance than calling them sequentially
# if NESTING is reasonably low (i.e 100)

require 'benchmark'

TIMES = 10000
# NESTING = 2000
# NESTING = 1000
# NESTING = 500
NESTING = 100

# write = proc {|x| p "Called #{x}"}
write = proc {|x| "Called #{x}"}
kernel = proc { write.("KERNEL") }

procs = Array.new(NESTING) do |i| 
  proc do |callable, param_to_callable| 
    write.("before #{i}") 
    callable.call(param_to_callable) 
    write.("after #{i}")
  end
end

nested = procs.inject(proc {|x| x.call}) {|acc, p| proc {|x| p.call(acc, x)}}

Benchmark.bmbm do |x|
  x.report("nested") {TIMES.times {
    nested.call(kernel)
  }}
  
  x.report("sequential") {TIMES.times {
    procs.each do |p|
      p.call(kernel)
    end
  }}
end