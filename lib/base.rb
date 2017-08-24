require "json"
require_relative "visible.rb"

class Base

  include Visible

  def self.counter
    @counter 
  end

  def self.counter=(c) 
    @counter = c
  end

  def initialize(data = nil)
    @id = self.class.counter
    self.class.counter = self.class.counter + 1
    data.each do |k, v| 
      if respond_to?("#{k}=")
        send("#{k}=", v)
      end
    end
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
    inst = new({})
    hash.each do |k, v|
      if inst.respond_to?("#{k}=")
        inst.send("#{k}=", v)
      end
    end
    inst
  end

  def self.gen_path(var_path)
    "../data/#{self.name.downcase}/#{var_path}.json"
  end

  def self.inherited(child) 
    if Dir.exist?("../data/#{child.name.downcase}")
       child.counter = Dir.glob("../data/#{child.name.downcase}/*.json").size + 1
    else
       Dir.mkdir("../data/#{child.name.downcase}")
        child.counter = 1
    end
  end

  def save
    File.write(self.class.gen_path(id), to_json)
  end

  def self.find(search_id) 
     path = gen_path(search_id)    
    if File.exist?(path)
      json_str = File.read(path).strip
      from_json(json_str)
    else
      nil
    end
  end

  def self.all 
    Dir.glob(gen_path("*")).map do |path|
      from_json(File.read(path).strip)
    end
  end

  def check_field_names(hash)
    hash.each do |k, v| 
      raise "field :#{k} not found for #{self.class.name}" unless self.respond_to? k
    end
  end

  def self.where(hash)
    raise "invalid argument" unless hash.kind_of?(Hash)
    findes = []
    objects = all
    objects[0].check_field_names hash

    objects.each do |o|
      valid = true
      hash.each do |k, v|
        if o.send(k) != v
          valid = false
          break
        end
      end
      findes << o if valid
    end
    findes
  end


  def self.table
    head, list = [], []
    find(1).to_hash.each do |k, v|
      head << k.to_s
    end
    objects = all
    objects.each do |item| 
      list.unshift(item.to_hash)
    end
    drow_table(list, head) 
  end

  def inspect 
    str = "#{self.class}("
    self.instance_variables.each do |var|
      str += var.to_s.delete('@') + ": \"" + self.instance_variable_get(var).to_s + "\", "
    end
    str.gsub /..$/, ')'
  end
end
