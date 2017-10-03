require_relative "../lib/base.rb"

class Item < Base 

 field :name, :string
 field :user_id, :integer
 field :list_id, :integer
 belongs_to :user, :list

end
