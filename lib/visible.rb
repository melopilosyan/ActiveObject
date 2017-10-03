require 'colorize'

module Visible

 private def max_chars(list, n) 
  items = []
  items << n.to_s
  list.each do |x| 
    items << x[n].to_s
  end
  items.map! do |x|
    x = x.length.even? ? x.length + 1 : x.length
  end
  items.max
 end

 private def table_width(list, h) 
  size = []
  h.each do |x| 
    size << max_chars(list, x.to_sym)
  end
  size
 end

 def drow_table(list, h)
  size = table_width(list, h)
  width = (size.sum + 3 * size.length)/2 + 1
  #puts self.name.colorize(:red) + "s".colorize(:red)
  puts("+ ".colorize(:blue) * width)
  h.each_with_index do |x, i| 
    print "+".colorize(:blue) + " #{x} ".colorize(:red) + (" " * (size[i] - x.length))
    print "+\n".colorize(:blue) if i == h.length - 1
  end
=begin
  list.sort_by! do |x| 
    x[:id]
  end
=end
  list.each do |val|
    puts("+ ".colorize(:blue) * width)
    i = 0
    val.each do |k, v|
      print "+".colorize(:blue) + " #{v} " + (" " * (size[i] - v.to_s.length))
      print "+\n".colorize(:blue) if i == h.length - 1
      i += 1 
    end
  end
  puts("+ ".colorize(:blue) * width) 
  end

  def self.included(base)
    base.extend Visible
  end

end
