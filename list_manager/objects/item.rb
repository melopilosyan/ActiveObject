require_relative '../../lib/base'

class Item < Base
  field :name, :string
  field :list_id, :integer
  field :user_id, :integer
  belongs_to :list
  belongs_to :user
end
