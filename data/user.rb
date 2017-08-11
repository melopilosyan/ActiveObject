class User
  attr_accessor :name, :surname
  attr_reader :age

  def initialize(name,surname)
    @name = name
    @surname = surname
  end

end
