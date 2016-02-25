require_relative 'db_conn'
require 'active_support/inflector'
require 'byebug'


class SQLObject
  def self.table_name
    @table_name ||= self.name.underscore.pluralize
  end

  def self.table_name=(name)
    @table_name = name
  end

# Next it is necessary to read the columns of the table

  def self.columns
# Here we are opening a connection with our SQL db
# and writing a very basic query for each data column in
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
    @results.first.map! { |col_name|  col_name.to_sym }

  end

# The first instance method we want define now is #attributes,
# which in ActiveRecod returns a hash of one relation's 
# column names and values. 
  def attributes
    @attributes ||= {}
  end
# This hash will be readied for populating when we call
# ::finalize! on our class. This creates getter and setter methods
#  for each column.

  def self.finalize!
    # Using the columns method above, iterate through each
    # existing column and use define_method like we did in
    # my_attr_accessor, except set/refer to the attrbutes 
    # hash rather than instance variables
    self.columns.each do |attribute|
      define_method("#{attribute}=") do |new_value|
        self.attributes[attribute] = new_value
      end

      define_method(attribute) do
        self.attributes[attribute]
      end
    end
  end

# Now when we call #new on our class, this

  def initialize(params = {})
    params.each do |key, value|
      key = key.to_sym
      if self.class.columns.include?(key)
        # We use .send to pass our argument to the setter
        # method if the class' columns include that attribute
        self.send("#{key}=", value)
      else
        raise "unknown attribute '#{key}'"
        # otherwise, raise the standard AR error.
      end
    end
  end

  # We can now write some of the foundation 
  # ActiveRed methods starting with :all

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    # at this point, all is a bunch of SQL Objects (hashes),
    #  but we want instances of our object, so we must parse
    parse_all(all)
  end

  def self.parse_all(sql_objects)
    # Iterate through the rows (hashes) received
    sql_objects.map do |row|
      # Since we are in a class method, self is the class
      # so we directly create a new instance with the information
      # from the hash
      self.new(row)
    end
  end

  # If we want to find a single object by ID
  # we need to make a copy of ActiveRecord's powerful #find method

  def self.find(id)
    # Using our ::all method would be inefficient, so
    # we write a query to return the single element
    result = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{id} = #{table_name}.id      
    SQL
    result.length >= 1 ? self.new(result.first) : nil
  end

  # We also need a method to augment our table
  # The heredoc isnert syntax is very specific, so we
  # need to do a little work to put it together, 
  # starting with gathering the attribute values
  # from the specific instance.

  def attribute_values
    # we iterate through the array of columns and send
    # our instance the getter method for that column name,
    # the output is an array of the attribute values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    # We have access to the values we want to insert
    # and now we need the specific heredoc syntax
    # to perform the SQL insertion.
    cols = self.class.columns.drop(1)
    col_names = cols.map(&:to_s).join(", ")
    qstn_marks = Array.new(cols.length, "?").join(", ")

    # The use of attribute_values here needs some explanation.
    # We use the splat operator on attribute values so
    # that they are arranged in order, excluding the first column
    # (id), which exists in attributes even before we've inserted
    # because #attribute values comes from the ::columns,
    # which includes the id attribute.

    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{qstn_marks})
    SQL

    # and finally we need to update our instance
    # with the id attribute that SQL assigned to it.
    # The #last_insert_row_id method gives us just that.
    self.id = DBConnection.last_insert_row_id
  end

# We also need to be able to update our data.
# This method works similarly to #insert with 
# different syntax for the heredoc.

  def update
    cols = self.class.columns
    set_line = cols.map {|col| "#{col} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

# Last, for now, we need the AR method #save
# which will call either insert or update
# depending on whether the entry already exists 
# in our table yet (aka whether it has an id)

  def save
    self.id.nil? ? insert : update
  end
  
end