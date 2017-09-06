require_relative "../../lib/base"

class List < Base
  field :name, :string
  field :user_id, :integer
  belongs_to :user
  has_many :items
end
