require "json"
require_relative "visible.rb"
require_relative "search.rb"

class Base

  attr_accessor :id

  include Search
  include Visible

  def self.counter
    @counter 
  end

  def self.counter=(c) 
    @counter = c
  end 


  def self.field_types  
    @field_types
  end

  def self.field_types=(o)
    @field_types = o
  end




  def initialize(data)

    return if data.nil?
    @id = self.class.counter
    self.class.counter = self.class.counter + 1
    data.each do |k, v| 
      if respond_to?("#{k}=")
        send("#{k}=", v)
      end
    end
  end

  def self.new(data = nil) 
    raise "\n> class Base is abstract and cant having instances " if self.name == "Base"
    super(data)
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
    inst = new()
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
    vars = self.instance_variables
    return str + ")" if vars.empty?
    vars.each do |var|
      str += var.to_s.delete('@') + ": \"" + self.instance_variable_get(var).to_s + "\", "
    end
    str.gsub /..$/, ')'
  end

  def self.field(name, type)
    if self.field_types.nil?
      self.field_types = {:id => "integer"}
    end
    self.field_types[name] = type.to_s
    attr_reader name
    define_method(name.to_s + "=") do |param|
      raise TypeError.new("expected #{type} but given #{param.class}") unless param.class.name.downcase == type.to_s.downcase 
      instance_variable_set("@"+ name.to_s, param)
    end
  end
end
