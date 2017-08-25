require "json"

class Base
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

    def array_id
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
      o.save
      o
    end

    def field(field_name, field_type)
      define_method("#{field_name}=") do |name|
        name

      end
      define_method("#{field_name}") do
        "@#{field_name}"
      end
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
      File.write self.class.file_path(id), to_json
    end
  end
