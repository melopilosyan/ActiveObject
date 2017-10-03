
require_relative "../../table/text-table.rb"

 table = Text::Table.new do |t|
    t.head = ['A', 'B', 'C']
    t.rows = [['a1', {value: 'b1', bmark: :red}, 'c1']]
    t.rows << [{mark: :red}, 'a2', 'b2', 'c3']
    t.rows << [{value: 'a3', mark: :blue}, 'b3', 'c3']
 end

 puts table
  
  class Array

    def chang(items, how)
      case items
      when Integer
        (items..(self.length-1)).each do |i| 
          self[i] = self[i].send(how)
        end
      when Range
        items.each do |i| 
          self[i] = self[i].send(how)
        end
      else
        msg = "expected \"Integer\" or \"Range\", given \"#{items.class}\""
        raise ArgumentError.new msg
      end
      self
    end

    def select_by_index(*indexes) 
      arr = []
      indexes.each do |i|
        if i > -1 && i < self.length
          arr << self[i]
        else
          msg = "undefined index #{i} for #{p self}"
          raise ArgumentError.new(msg)
        end
      end
      arr
    end

  end
  
  #p ['1', '2', '3', '4', '5'].chang(0, :to_i)
  #p ['1', '2', '3', '4', '5'].select_by_index(0, 4, 1, 3, 3)

 
 
  
