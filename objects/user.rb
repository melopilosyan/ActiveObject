require_relative "../lib/base"

class User < Base
  attr_accessor :name, :surname, :id

  def initialize(name = nil, surname = nil)
    @name = name
    @surname = surname
    @id = rand 1000
  end

end

