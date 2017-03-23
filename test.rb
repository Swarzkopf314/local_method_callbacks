
# h = [[4,5], [4,6], [1,3], [1,2], [5,8]]

# p h.group_by {|(k,v)| k}

# exit

require 'benchmark'

n = 100

write = proc {|x| "wywołano #{x}"}
kernel = proc { write.("KERNEL") }

procs = Array.new(5000) do |i| 
  proc {|callable| write.("before #{i}"); callable.call(); write.("after #{i}") }
end

def decorate_proc_with_block(prc)
  proc {yield(prc)}
end

Benchmark.bmbm do |x|
  x.report("nested") {n.times {
    procs.inject(kernel) {|acc, n| decorate_proc_with_block(acc, &n)}.call
  }}
  
  x.report("sequential") {n.times {
    procs.each do |n|
      n.call(proc {})
    end
  }}
end