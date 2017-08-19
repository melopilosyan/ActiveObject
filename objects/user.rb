require "json"

class User
  attr_accessor :name, :surname, :id

  def initialize(name,surname)
    @name = name
    @surname = surname
    @id = rand 1000
  end
  def to_js
	  user = {}
	  self.instance_variables.each do |var|
		  user[var.to_s.delete("@")] = self.instance_variable_get var
	  end
	  JSON.generate(user)
  end
end


