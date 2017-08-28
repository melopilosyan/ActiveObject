require_relative "../objects/user.rb"
require_relative "../objects/post.rb"

#User.new(name: "name_1", surname: "surname_1", age: 1).save
#User.new(name: "name_2", surname: "surname_2", age: 2).save
#User.new(name: "name_1", surname: "surname_2", age: 3).save
#User.new(name: "name_2", surname: "surname_1", age: 4).save

#select = User.where(name: "name_1")

select = User.where("name == name_1")

puts
select.each do |o| 
  p o
end
puts



#u = User.new(name: "hvjhvj")
#p u
#a = User.new.to_hash
#p a
#User.table
#puts User.field_types
#puts Post.field_types
