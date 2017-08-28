require_relative "../lib/base"

class User < Base
   field :name, :string
   field :surname, :string
   field :age, :integer
   has_many :posts
end

