require_relative "../lib/base"

class User < Base
   field :name, :string
   field :surname, :string
   field :age, :integer
   field :email, :string
   field :password, :string
   has_many :posts
   before_destroy :delete_posts, :on_destroy
   before_save :check_name

   def delete_posts
     self.posts.each do |post|
       post.delete
     end
   end

   def on_destroy
     puts "on users destroy #{self.id}"
   end

   def check_name
      self.name = "Vzzzzzzzgo" if self.name.nil? || self.name.empty?
   end

end

