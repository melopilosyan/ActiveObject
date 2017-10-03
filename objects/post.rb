require_relative "../lib/base.rb"

class Post < Base
 
  field :title, :string
  field :description, :string
  field :user_id, :integer
  belongs_to :user

   
end


