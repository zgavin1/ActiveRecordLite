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