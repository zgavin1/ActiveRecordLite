#Active Record Lite

ARL is a code intensive program built to facilitate a cohesive and easy to use back-end architecture with Ruby and SQL. The classes within build on one another to ultimately create a way to build a SQL table with the functionality outlined below whenever a class in Ruby is instantiated as a subclass of SQLObject.


### SQLObject

This class will serve as the parent for any Ruby classes that we wish to generate a link with our SQL database. It has class methods, as well as instance methods. Many of the methods rely on heredoc syntax to generate raw SQL queries.

#### SQLObject::columns
This class method returns to us the names of the columns for our class's table in SQL. This method requires that we either know the table by name already, or we have a way to see what it would be, which leads us to...

#### SQLObject::table_name and ::table_name=
The setter and getter methods for SQL table name. This relies on Ruby convention for classes to be singular camel case and creates SQL tables in plural snake case. 

#### SQLObject::finalize! and #attributes
The class method finalize! is called when we are ready to set up the foundation of our class-to-table relationship, retrieving the column names, and creating elements of our @attributes instance variable hash out of those names.

#### SQLObject#initialize
When we initialize an object of our class, we test to see if that params passed to it match up with the columns of that class' SQL table.

#### SQLObject::all and ::parse_all
Together these two class methods return an array of Objects of that specific class, one for each row in that class' associated table.

#### SQLObject::find(id)
This class method sets up a SQL query with a WHERE line to match on the id column in that class' table, returning either the correct object or nil.

#### SQLObject#attribute_values, #insert, #update, #save
These instance methods create the structure for pushing more rows into our table and editing existing rows' data.





### attr_accessor.rb

This file is actually not directly used in the rest of the code

