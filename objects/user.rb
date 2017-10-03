require_relative "../lib/base.rb"

class User < Base

  field :name, :string
  field :surname, :string
  field :login, :string
  field :password, :string
  
  has_many :lists, :items, :posts
=begin
  before_create :create_1
  before_create :cr
  after_create :create_2
  before_update :update_1
  after_update :update_2
  before_delete :delete_1
  after_delete :delete_2
  before_save :save_1
  after_save :save_2
=end


  def full_name
    "#{name} #{surname}"
  end

  def create_1 
    puts "start create_1"
  end

  def cr
    puts "start_create_2"
  end

  def create_2
    puts 'end create'
  end

  def update_1 
    puts "start update"
  end

  private
  def update_2 
    puts "end update"
  end

  def delete_1 
    puts "start delete"
  end
  private :delete_1

  def delete_2 
    puts "end delete"
  end

  def save_1 
    puts "start save"
  end
 
  def save_2 
    puts "end save"
  end
 
  private :save_1, :save_2
end





