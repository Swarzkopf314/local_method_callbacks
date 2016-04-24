module LocalMethodCallbacks
	module Configuration

		def configuration
			@configuration ||= default_configuration
		end

		def set_configuration(config = nil)
			@configuration = config || default_configuration
		end

		def configure
			yield(configuration)
		end

		def default_configuration
			OpenStruct.new
		end

	end
end