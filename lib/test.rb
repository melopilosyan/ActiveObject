require 'json'
require_relative '../objects/user'
print "User name: "
name = gets.chomp
print "User surname: "
surname = gets.chomp
user = User.new name,surname



f = File.open('data/test.json' , "a") 
f.puts user.to_js
File.readlines('data/test.json').each do |line|
	 user = JSON.parse(line)
	 puts "#{user["name"] } #{user["surname"]}"
end


