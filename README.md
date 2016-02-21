#Active Record Lite

ARL is a code intensive program built to facilitate a cohesive and easy to use back-end architecture with Ruby and SQL. The classes within build on one another to ultimately create a way to build a SQL table with the functionality outlined below whenever a class in Ruby is instantiated as a subclass of SQLObject.

As of now, I have borrowed code for the database connection, and for my specs. As soon as possible, these files will be updated with my own code.


### SQLObject

This class will serve as the parent for any Ruby classes that we wish to generate a link with our SQL database. It has class methods, as well as instance methods. Many of the methods rely on heredoc syntax to generate raw SQL queries.

#### SQLObject::columns
This class method returns to us the names of the columns for our class's table in SQL. This method requires that we either know the table by name already, or we have a way to see what it would be, which leads us to...

#### SQLObject::table_name and ::table_name=
The setter and getter methods for SQL table name. This relies on Ruby convention for classes to be singular camel case and creates SQL tables in plural snake case. 

#### SQLObject::finalize! and #attributes
The class method finalize! is called when we are ready to set up the foundation of our class-to-table relationship, retrieving the column names, and defining getter and setter instance methods for each attribute (column) of our class.

#### SQLObject#initialize
When we initialize an object of our class, we test to see if that params passed to it match up with the columns of that class' SQL table.

#### SQLObject::all and ::parse_all
Together these two class methods return an array of Objects of that specific class, one for each row in that class' associated table.

#### SQLObject::find(id)
This class method sets up a SQL query with a WHERE line to match on the id column in that class' table, returning either the correct object or nil.

#### SQLObject#attribute_values, #insert, #update, #save
These instance methods create the structure for pushing more rows into our table and editing existing rows' data.


### Searchable Module
This module contains just one powerful method providing the cabability to query our table for rows with a specifity attribute val.

#### Searchable#where
This method writes a SQL query with a heredoc to return specific rows matching the provided parameters. We parse our SQL returns with the class method defined in SQLObject such that it returns objects of the desired Class, rather than just raw SQL objects.


### Associatable Module
This module creates the methods required to generate associations between Ruby objects, such as a User "has many" Posts, or a Comment "belonging to" an Author. The SQLObject is extended with this module. There are three new classes we build to handle this pattern of data organization.

The "having" object is the one that carries references to many "belonging" objects. These objects share references to one another through three pieces of information: foreign_key, primary_key, and class_name. 

#### AssocOptions
This class is built to keep the code DRY. It stores attr_accessor capability on the major Associatable information from above, as well as a reference to that class' SQL table, all of which is need in both of the next classes, which inherit from AssocOptions.

#### BelongsToOptions and HasManyOptions
These classes create default names based on the class names for the hash keys that compose the engine of these associations.

#### Associatable#has_many, #belongs_to
These methods work similarly. We can pass a name of the the potential association class (in snake_case, belongs_to expects a singular name, has_many expects a pluralized name. We can also pass a hash in some cases to override the default names for our parameters. With this information, we create instances of the appropriate "Options" class, and define a method on the original 'name' argument that returns either the array of associated objects if we're calling from a has_many object, or the single association if calling from a belongs_to object.
This is produced with a SQL query, that relies on our earlier Searchable::where method to match up foreign_keys and primary_keys.

#### Associatable#has_one_through
This method simply takes the previous functions a step further, looking at the association of an association.




### attr_accessor.rb

This file is actually not directly used in the rest of the code yet, it is simply an exercise I am working on to extend this project further. Check back soon for more information.

