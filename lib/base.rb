require_relative "../objects/user"
class Base
 attr_accessor :users

 def initialize
   @users = {}
 end

 def add 
  print "User name: "
  name = gets.chomp
  print "User surname: "
  surname = gets.chomp
  a = "Do you want to save user? (y/n)"
  puts a
  answer = gets.chomp.to_s
    while answer
      case answer
        when "y"
         user = User.new name, surname
         f = File.open('data/user.json' , "a")
         f.puts user.to_js
         puts " Account is saved"
        break
	when "n"
          puts " Account is not saved"
	break
     else 
      puts"No valid command, try again!"
      puts a
      answer = gets.chomp.to_s
     end
    end
 end
 
 def all_users
  File.readlines('data/user.json').each do |line|
    user = JSON.parse(line)
    user_id = user["id"]
    @users[user_id]= user
    end
   @users.each do |key, value|
     puts "#{value["name"]} #{value["surname"]}" 
   end
 end

 def get_user_byId id
  @users.has_key?(id) ? "User name: #{@users[id].name} by id:#{id}" : "Hasn't user with id : #{id}" 
 end 
end
