require "json"
require "active_support/inflector"

module Utils
  def class_exist?(class_name)
    klass = Module.const_get(class_name.to_s.classify)
    klass.is_a? Class
  rescue 
    false
  end

end

class String
  def class?
    klass = Module.const_get(self.classify)
    klass.is_a? Class
  rescue
    false
  end
end

class Symbol
  def class?
    to_s.class?
  end
end
