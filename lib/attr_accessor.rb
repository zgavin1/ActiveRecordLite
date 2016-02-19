# This file is a simple recreation of the
# attr_accessor property that we assign to 
# certain instance variables within
# Ruby classes.

class AttrAccessorClass
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method("#{name}=") do |new_value|
        instance_variable_set("@#{name}", new_value)
      end

      define_method("#{name}") do
        instance_variable_get("@#{name}")
      end
    end
  end
end