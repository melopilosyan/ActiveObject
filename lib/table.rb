require 'colorize'

class Table
      
  attr_accessor :width, :cols, :maxes, :color
  private :width, :cols, :maxes, :color

  def initialize(data, c = :white) 
    @cols = []
    @maxes = []
    data_validation(data, c)
    set_cols(data)
    set_maxes
    set_width
    self.color = c
    drow_table(data)
  end

  private

  def set_maxes 
    cols.each do |col| 
      a = col.map do |item| 
        item.to_s.length
      end
     maxes << a.max
    end
  end

  def set_width 
    col_count = cols.length
    self.width = maxes.sum + (3 * col_count) + 1
  end

  def set_cols(data) 
    data[0].length.times do |i|
      cols << []
      data.each_with_index do |item|  
        cols.last << item[i]
      end
    end
  end

  def drow_table(tab)
    puts ("." * width).send(color)
    tab.each do |row|
      #start_row
      contain_row(row)
      end_row
    end
  end

  def start_row
    maxes.each_with_index do |max, i|
      print ":".send(color) + " " * (maxes[i] + 2)
    end
    print ":\n".send(color)
  end

  def end_row
    maxes.each do |max| 
      print ":".send(color)
      print ("." * (max + 2)).send(color)
    end
    print ":\n".send(color)
  end

  def contain_row(row)
    print ":".send(color)
    row.each_with_index do |item, i|
      size = maxes[i] - item.to_s.length + 1
      print " #{item}".blue + " " * size + ":".send(color)
    end
    print "\n"
  end

  def data_validation(tab, c)
    tab.each do |item|
      if !tab.kind_of?(Array) 
        msg = arg_err_msg(:Array, item.class)
        ex(ArgumentError, msg)
      end
      if item.length != tab[0].length 
        raise "invalid length in #{item}".red
      end
    end

    colors = [:red, :blue, :yellow, :white]
    unless colors.include? c.to_sym
      msg = "invalid color: #{c}".red
      ex(ArgumentError, msg)
    end
  end

  def ex(type, msg) 
    raise type.new(msg)
  end

  def arg_err_msg(expected, given) 
    "expected #{expected} but given #{given}".red
  end

end

tab = [[:id, :name, :surname, :password], [1, :Davit, :ghfghf, :kfkyfyf], [2, :Aram, :jgfjhjfj, :hjgj], [3, :Gevorg, :kjhkjghgj, :hfdhhd]]
Table.new(tab)


  


