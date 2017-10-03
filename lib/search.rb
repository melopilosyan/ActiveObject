module Search
 
  def find(search_id) 
     path = gen_path(search_id)    
    if File.exist?(path)
      json_str = File.read(path).strip
      from_json(json_str)
    else
      nil
    end
  end

  def all 
    Dir.glob(gen_path("*")).map do |path|
      from_json(File.read(path).strip)
    end
  end

  def check_field_names(hash)
    inst = new()
    hash.each do |k, v| 
      raise "field :#{k} not found for #{self.class.name}" unless inst.respond_to? k
    end
  end

  def check_condition(cond) 
    length = cond.length
    valides = [">", "<", ">=", "<=", "==", "!="]
    raise ArgumentError.new("invalid condition #{cond[1]}") if length != 3 || !(valides.include? cond[1])
  end

  def when_hash(cond, objects, findes)

    check_field_names(cond)
      
      objects.each do |o|
        valid = true
        cond.each do |k, v|
          if o.send(k) != v
            valid = false
            break
          end
        end
        findes << o if valid
      end
      findes
  end

  def check_comparable(c1, c2)
    type =  field_types[c1.to_sym]
    
    case type
      when "integer"
        return c2.to_i
      when "float"
        return c2.to_f
      else
        return c2
      end
  end

  def when_string(cond, objects, findes) 
    c = cond.split
    check_condition(c)
    objects.each do |o|
      raise ArgumentError.new("invalid name_field \"#{c[0]}\" for #{o.class}") unless o.respond_to? c[0]
      field_val = o.send(c[0])
      next if field_val.nil?
      if field_val.respond_to? c[1]
        c[2] = check_comparable(c[0], c[2])
        begin
          if field_val.send(c[1], c[2])
            findes << o
          end
        rescue ArgumentError
          next
        end
      else
        raise ArgumentError.new("invalid condition #{c[1]}")
      end
    end
    findes
  end

  def where(cond)
    raise ArgumentError.new("given #{cond.class} but expected Hash or String") unless cond.kind_of?(Hash) || cond.kind_of?(String) 
    findes = []
    objects = all

    case cond
      when Hash
        when_hash(cond, objects, findes)
      when String
        when_string(cond, objects, findes)
    end
  end
end
