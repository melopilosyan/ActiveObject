require "json"

class Base
  attr_accessor :id

  def self.inherited(child)
    if Dir.exist?("data/#{child.name.downcase}")
     child.count = Dir.glob("data/#{child.name.downcase}/*.json").size
    else
      Dir.mkdir("data/#{child.name.downcase}")
      child.count = 0
    end
  end
  
  def self.count=(count)
    @count = count
  end

  def self.next_id
    @count += 1
  end

  def initialize(hash = nil)
   @id = self.class.next_id  
   self.update hash
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

  def update(hash)
    unless  hash.kind_of? Hash
      return self
    end
    hash.each do |k,v|
      if self.respond_to?("#{k}=")
        self.send "#{k}=", v
      end
    end
    self
  end

  def self.from_hash(hash)
    new.update hash
  end

  def save
    File.write self.class.file_path(id), to_json
  end

  def self.search_by_id(id)
    if File.exist? file_path(id)
      from_json File.read file_path(id)
    else
      nil
    end

  end

  def self.file_path(id)
    "data/#{self.name.downcase}/#{id}.json"
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
  
end
