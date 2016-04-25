module LocalMethodCallbacks
	class Logger < Callbacks

		# override
		def self.default_configuration
			super.tap do |config|
				config.pass_receiver = true
				config.pass_method_name = true
			end
		end


	end
end