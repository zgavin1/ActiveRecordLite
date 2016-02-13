class MyAttrAccessorClass
	def my_attr_accessor(*names)
		names.each do |name|
			define_method("#{name}=()") do |new_value|
				instance_variable_set("@#{name}", new_value)
			end

			define_method("#{name}") do
			 	instance_variable_get("@#{name}")
			end
		end
	end
end


class SQLObject

# The very first thing we need is a way to set 
# and reference the table associated with this object

	def self.table_name
		@table_name ||= self.name.tableize
	end

	def self.table_name=(name)
		@table_name = self.name.to_s.tableize
	end

# Next it is necessary to read the columns of the table

	def self.columns
# Here we are opening a connection with our SQL db
# and writing a very basic query for all the data in
# our specific table.

# The expense of this databse query should only be taken
# once, before @results has been given value,
# and the return stored in an instance variable.
		@results ||= DBConnection.execute2(<<-SQL)
			SELECT
				*
			FROM
				#{table_name}
		SQL
# Here, the result of #execute2 has been stored,
# and we know that the first result of the return
# is a subarray of the column names, which we 'symbolize'
		@results.first.map { |col_name|  col_name.to_sym }
	end

# The first instance method I want define now is #attributes,
# which in ActiveRecod returns a hash of one relation's 
# column names and values. 
	def attributes
		@attributes ||= {}
	end
# This hash will be readied for populating when we call
# ::finalize! on our class. This creates getter and setter methods
#  for each column.

	def self.finalize!
		columns.each do |attribute|
			define_method("#{attribute}=()") do |new_value|
				attributes[attribute] = new_value
			end

			define_method(attribute) do
			 	attributes[attribute]
			end
		end
	end
end