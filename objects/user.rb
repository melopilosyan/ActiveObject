require_relative "../lib/base"

class User < Base
   field :name, :string
   field :surname, :string
   field :age, :integer
   field :email, :string
   field :password, :string
   has_many :posts
   before_destroy :delete_posts, :on_destroy
   after_destroy :after_delete
   before_save :check_name
#   after_save :after_save
   def delete_posts
     self.posts.each do |post|
       post.delete
     end
   end

   def after_delete
	   if !self.posts.empty?
	   puts "User and posts are deleted"
	   else
		   puts "User is deleted"
	   end
   end

   def on_destroy
     puts "on users destroy #{self.name}"
   end

   def after_save
	   puts "user is savedddd"
   end

   def check_name
      self.name = "Vzzzzzzzgo" if self.name.nil? || self.name.empty?
   end

end

