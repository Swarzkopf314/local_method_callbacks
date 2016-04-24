module LocalMethodCallbacks
	module Configuration

		def configuration
			@_configuration ||= OpenStruct.new
		end

		def configure
			yield(configuration)
		end

	end
end