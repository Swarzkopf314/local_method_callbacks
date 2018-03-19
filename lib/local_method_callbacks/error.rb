module LocalMethodCallbacks
  # http://blog.honeybadger.io/ruby-exception-vs-standarderror-whats-the-difference/
  # bald "rescue" catches StandardError, but not Exception
  class Error < StandardError
  end
end