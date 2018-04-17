module LocalMethodCallbacks
  # http://blog.honeybadger.io/ruby-exception-vs-standarderror-whats-the-difference/
  # bold "rescue" catches StandardError, but not Exception
  class Error < StandardError
  end

  class UnhandledGemError < Error
  end

end