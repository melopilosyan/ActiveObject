require "json"

class Base

  def initialize
  end

  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      hash[var.to_s.delete('@').to_sym] = self.instance_variable_get var
    end
    hash
  end

  def to_json
    JSON.generate to_hash
  end
   
  def self.from_json(json_string)
   from_hash JSON.parse(json_string)
  end
  
  def self.from_hash(hash)
    o = new
    hash.each do |k,v|
      if o.respond_to?("#{k}=")
        o.send "#{k}=", v
      end
    end
    o
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
        f = File.open('data/.json' , "a")
        f.puts user.to_js
        f.close
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
  
  def delete_all_users
  end

end
