module LocalMethodCallbacks
	class Logger < CallbackChain

		# override
		def self.default_configuration
			super.tap do |config|
				config.pass_receiver = true
				config.pass_method_name = true
				config.instance_eval = true
			end
		end


	end
end