require_relative 'ar_lite_1'
require 'db_connection'
# This file will be a model to emulate 
# ActiveRecord's searchable module

module Searchable
	# This where method takes a hash argument
	# of values by column to match with records
	# in our db
	def where(params)
		# We map the params to the correct heredoc syntax
		where_line = params
			.map { |key, value| "#{key} = ?" }
    	.join(" AND ")

    # we store the results to be parsed
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
	end
end


# And we want to actually grant SQLObject class this capability
class SQLObject
	extend Searchable
end