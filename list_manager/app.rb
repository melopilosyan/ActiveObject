require_relative "objects/user"
require_relative "objects/item"
require_relative "objects/list"
require "colorize"

class App

  def first_page
    under_line = "___________________________________"
    puts "#{under_line}List Manager#{under_line}".blue.bold
    puts "\n\nActive Lists".bold.blue




  end


app = App.new
app.first_page
end

