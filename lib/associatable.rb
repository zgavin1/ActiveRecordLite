require_relative 'db_connection'
require_relative 'searchable'

# We want a module to mixin with SQLObject that contains
# the esential association logic
module Associatable
	def has_many(name, options = {})
		self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

		define_method(name) do
			options = self.class.assoc_options[name]

			frgn_key = self.send(options.primary_key)
			options.model_class.where(options.foreign_key => frgn_key)
		end
	end

	def belongs_to(name, options = {})
		self.assoc_options[name] = BelongsToOptions.new(name, options)

		define_method(name) do
			options = self.class.assoc_options[name]

			frgn_key = self.send(options.foreign_key)
			options.model_class.where(options.primary_key => frgn_key).first
		end
	end

	def assoc_options
		@assoc_options ||= {}
		@assoc_options
	end

	def has_one_through(name, through_name, source_name)
		define_method(name) do 
			through_options = self.class.assoc_options[through_name]

			key_val = self.send(through_options.foreign_key)

			source_options = through_options.model_class.assoc_options[source_name]

			# table = source_options.model_class.table_name


			results = DBConnection.execute(<<-SQL, key_val)
				SELECT
					#{source_options.table_name}.*
				FROM
					#{through_options.table_name}
				INNER JOIN
					#{source_options.table_name}
						ON #{source_options.table_name}.#{source_options.primary_key} = #{through_options.table_name}.#{source_options.foreign_key}
				WHERE
					#{through_options.table_name}.#{through_options.primary_key} = ?
			SQL

			source_options.model_class.parse_all(results).first
		end
	end
end

# To write the above Associatable module, we need some classes
# to store the pieces of the association relationship:
# foreign key, primary key, and class name.

# We'll first write another module,
# AssocOptions to store this info.

class AssocOptions
	attr_accessor :foreign_key, :primary_key, :class_name

	def model_class
		@class_name.constantize
	end

	def table_name
		model_class.table_name
	end
end

# now we write to classes which extend this module
# and hold set up default values

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

class SQLObject
	extend Associatable
end

