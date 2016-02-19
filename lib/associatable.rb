require_relative 'db_connection'
require_relative 'searchable'
require_relative 'has_many_options'
require_relative 'belongs_to_options'
require_relative 'assoc_options'

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


class SQLObject
	extend Associatable
end

