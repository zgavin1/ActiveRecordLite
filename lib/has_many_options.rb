require_relative 'assoc_options'

class HasManyOptions < AssocOptions
	def initialize(name, class_name, options = {})
		defaults = {
			:primary_key => :id,
			:foreign_key => (class_name.to_s.downcase + "_id").to_sym,
			:class_name => name.to_s.singularize.camelcase
		}

		defaults.keys.each do |key|
			self.send("#{key}=", options[key] || defaults[key])
		end
	end
end