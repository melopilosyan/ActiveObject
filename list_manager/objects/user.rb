require_relative '../../lib/base'
require_relative 'list'
require_relative 'item'

class User < Base
  field :name, :string
  field :surname, :string
  field :email, :string
  field :password, :string
  has_many :lists
  has_many :items
  after_destroy :delete_lists

  #
  def add_list(name)
    List.create name: name, user_id: self.id    
  end
  
  # Optional description for the function
  #
  # @param [String] name
  # @param [integer] list_id
  # @return [Item/nil]
  def add_item(name, list_id)
    list = List.search_by_id list_id
    return nil if list.nil?
    has_item = false
    list.items.each do |item|
      if item.user_id == self.id
        has_item = true
        puts "has item"
        break
      end
    end
    item = Item.create(name: name, user_id: self.id, list_id: list_id) if has_item == false
  end
  
  def delete_lists
    self.lists.each do |list|
      list.delete
    end
  end

end
