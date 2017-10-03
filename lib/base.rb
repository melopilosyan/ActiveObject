require "json"
require_relative "../lib/visible.rb"
require_relative "../lib/search.rb"
require "active_support/inflector"

class Base

  attr_accessor :id

  extend Search
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
      else
        puts "object hasnt #{k} "
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

  def self.table
    head, list = [], []
    begin
      find(1).to_hash.each do |k, v|
        head << k.to_s
      end
    rescue NoMethodError
      puts "#{self}s table is empty"
      return
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
      unless param.class.name.downcase == type.to_s.downcase
        raise TypeError.new("expected #{type} but given #{param.class}") 
      end
      instance_variable_set("@"+ name.to_s, param)
    end
  end

  def self.get_class(class_name)
    klass = Module.const_get(class_name)
    if klass.is_a?(Class)
      return klass
    else
      raise NameError.new
    end
    rescue NameError
      raise ArgumentError.new("class \"#{class_name}\" not defined")
  end

  def self.has_many(*list)
    list.each do |class_name|

      define_method(class_name) do
        klass = self.class.get_class(class_name.to_s.classify)
        klass.where("#{self.class.name.downcase}_id == #{self.id}")
      end

      define_method("add_" + "#{class_name}".singularize) do |o|
        node_id = self.class.name.downcase + "_id"
        o.instance_variable_set("@" + node_id, id)
        o.define_singleton_method(node_id) do 
          instance_variable_get("@" + node_id)
        end
        o.save
      end
    end

  end 

  def self.belongs_to(*class_names)
    class_names.each do |class_name|
      define_method(class_name) do
        klass = self.class.get_class(class_name.to_s.capitalize)
        klass.find(send("#{class_name}_id"))
      end
    end
  end

  def save
    b_save if respond_to? "b_save"
    File.write(self.class.gen_path(id), to_json)
    a_save if respond_to? "a_save"
    self
  end

  def self.create(data = nil)
    o = new(data)
    o.b_create if o.respond_to? "b_create"
    o.save
    o.a_create if o.respond_to? "a_create"
    o
  end
  
  def update(hash)
    b_update if respond_to? "b_update"
    unless hash.kind_of?(Hash)
      raise ArgumentError("given #{hash.class}, expectid Hash")
    end
    hash.each do |k, v| 
      if respond_to? k 
        send("#{k}=", v)
      else
        raise ArgumentError.new("#{k} is not variable")
      end
    end
    save 
    a_update if respond_to? "a_update"
    self
  end
  
  def delete
    b_delete if respond_to? "b_delete"
    File.delete(self.class.gen_path(id)) 
    a_delete if respond_to? "a_delete"
  end

  def self.aft_bef(name)
    self.define_singleton_method(name) do |*met_list|
      self.set_calls("@@#{name}", met_list)
      define_method("#{name[0]}_#{name.split("_")[1]}") do
        calls = self.class.get_calls("@@#{name}")
        calls.each do |met| 
          send(met)
        end
      end
    end
  end 

  def self.get_calls(var_name) 
    self.class_variable_get(var_name)
  end

  def self.set_calls(var_name, list)
    if self.class_variable_defined?(var_name)
      a = self.get_calls(var_name) + list
      self.class_variable_set(var_name, a)
    else
      self.class_variable_set(var_name, list)
    end
  end

  aft_bef("before_save")
  aft_bef("before_delete")
  aft_bef("before_update")
  aft_bef("before_create")
  aft_bef("after_save")
  aft_bef("after_delete")
  aft_bef("after_update")
  aft_bef("after_create")
  
end



  
