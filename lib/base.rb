require_relative "utils"

class Base
  include Utils
  attr_accessor :id
  
  class << self

    def inherited(child)
      if Dir.exist?("data/#{child.name.downcase}")
        child.count = Dir.glob("data/#{child.name.downcase}/*.json").size
      else
        Dir.mkdir("data/#{child.name.downcase}")
        child.count = 0
      end
    end

    def count=(count)
      @count = count
    end

    def next_id
      @count += 1
    end

    def ids_in_array
      Dir.glob("data/user/*.json").map do |user|
        user.split("/").last.split(".").first.to_i
      end
    end

    def all
      Dir.glob(file_path('*')).map do |file_name|
        from_file file_name
      end
    end

    def from_hash(hash)
      new hash
    end

    def from_json(json_string)
      from_hash JSON.parse(json_string)
    end

    def from_file(file_name)
      from_json File.read file_name
    end

    def search_by_id(id)
      if File.exist? file_path(id)
        from_file file_path(id)
      else
        nil
      end
    end

    def where(hash)
      a = []
      all.each do |o|
        valid = true
        hash.each do |k,v|
          if  o.send(k) != v
            valid = false
            break
          end
        end
        a.push o if valid
      end
      a
    end

    def file_path(id)
      "data/#{self.name.downcase}/#{id}.json"
    end

    def create(hash)
      o = new hash
    self.class.before_create_func.each do |callback|
      self.send callback
    end
      o.save
    self.class.after_create_func.each do |callback|
      self.send callback
    end
    o
    end

    def field(field_name, field_type)
      define_method("#{field_name}=") do |param|
        raise TypeError, "Expected #{field_type.to_s.capitalize} given #{param.class}" if param.class.name.downcase != field_type.to_s
        instance_variable_set "@#{field_name}", param
      end
      attr_reader field_name
    end

    def belongs_to(class_name)
        define_method(class_name) do
          klass = Module.const_get(class_name.to_s.capitalize)
        klass.search_by_id send("#{class_name}_id") 
        end
    end

    def has_many(class_name)
      define_method(class_name) do
        klass = Module.const_get(class_name.to_s.classify)
        klass.where "#{self.class.name.downcase}_id".to_sym => id
      end
      #raise NameError, "Given #{class_name} expected existing class name"
    end
    
    def define_event_handlers_for(event_name)
      define_singleton_method("before_#{event_name}_func") do
        instance_variable_get("@before_#{event_name}_func") || []
      end

      define_singleton_method("after_#{event_name}_func") do
        instance_variable_get("@after_#{event_name}_func") || []
      end

      define_singleton_method("before_#{event_name}") do |*call_back_list|
        instance_variable_set "@before_#{event_name}_func", [] if instance_variable_get("@before_#{event_name}_func").nil?
        instance_variable_get("@before_#{event_name}_func").concat call_back_list
      end

      define_singleton_method("after_#{event_name}") do |*call_back_list|
        instance_variable_set "@after_#{event_name}_func", [] if instance_variable_get("@after_#{event_name}_func").nil?
        instance_variable_get("@after_#{event_name}_func").concat call_back_list
      end


    end

  def delete_all
    all.each do |o|
      o.delete 
    end
    true
  end


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

  def to_s
    s = "#{self.class}("
    self.to_hash.each do |k,v|
      if v.is_a? String
        s += "#{k}: \"#{v}\", "
      else
        s += "#{k}: #{v}, "
      end
    end
    s.gsub /..$/, ')'
  end
  alias :inspect :to_s

  def update(hash)
    return self unless  hash.kind_of? Hash
    hash.each do |k,v|
      if self.respond_to?("#{k}=")
        self.send "#{k}=", v
      end
    end
    self
  end

  def save
    self.class.before_save_func.each do |callback|
      self.send callback
    end

    File.write self.class.file_path(id), to_json

    self.class.after_save_func.each do |callback|
      self.send callback
    end
    true
  end

  def delete
    self.class.before_destroy_func.each do |callback|
      self.send callback
    end

    result = nil
    result = File.delete self.class.file_path(id) if File.exists? self.class.file_path(id)

    self.class.after_destroy_func.each do |callback|
      self.send callback
    end
    result
  end
  


  define_event_handlers_for :destroy
  define_event_handlers_for :save
  define_event_handlers_for :create
end
