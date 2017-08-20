require 'json'
require_relative 'base'

base = Base.new
com = "Input 0 for EXIT , 1 for REGISTRATION , 2 for SEE ALL USERS"
puts com
input = gets.chomp.to_i
while input 
	case input
	when 0
		puts"exit"
		break
	when 1
		base.add
		puts com
		input = gets.chomp.to_i
	when 2
		puts " All users are: "
	      base.all_users
	      puts com
	      input = gets.chomp.to_i
	end
end
