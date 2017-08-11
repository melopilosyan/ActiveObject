class User
  attr_accessor :name, :surname

  def initialize(name,surname)
    @name = name
    @surname = surname
    @age = 0
  end
end
