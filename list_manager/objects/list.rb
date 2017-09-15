require_relative "../../lib/base"

class List < Base
  field :name, :string
  field :user_id, :integer
  belongs_to :user
  has_many :items
  after_destroy :delete_items

  def delete_items
    self.items.each do |item|
      item.delete
    end
  end


end
