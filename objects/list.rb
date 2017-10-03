require_relative "../lib/base.rb"

class List < Base

  field :name, :string
  field :user_id, :integer
  has_many :items
  belongs_to :user
  

end
