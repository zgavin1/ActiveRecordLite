class BelongsToOptions < AssocOptions
	def initialize(name, options = {})
		defaults = {
			:primary_key => :id,
			:foreign_key => (name.to_s + "_id").to_sym,
			:class_name => name.to_s.camelcase
		}

		defaults.keys.each do |key|
			self.send("#{key}=", options[key] || defaults[key])
		end
	end
end