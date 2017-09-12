require "colorize"
require "highline/import"
require "table_print"
require "text-table"

require_relative "objects/user"
require_relative "objects/item"
require_relative "objects/list"
require_relative "helpers/notifier"


class App

  def first_page
    title "List Manager"
     case menu :Exit, "Sign In", "Sign Up", "Active Lists"
     when 1
      # sign_out
     when 2 
       sign_in
     when 3
       sign_up
       my_page
     when 4
       list_table
       change_list_menu
     else
       first_page
     end
  end
  
    def title(title)
      l = (60 - title.length - 2 ) / 2
      line = (" " *  l).colorize background: :blue
      puts "\n#{line} #{title.blue} #{line}\n\n"

    end


  def sign_in
    title "Sign In"
    if !User.any?
      puts "\nFor Sign In first Sign Up".blue
      yes_or_no.downcase == 'y' ? sign_up : first_page
    else
      email = ask("\nEnter your Email: ".blue)
      password = ask("Enter your Password: ".blue) {|q| q.echo = "*"}
      @user = User.where(email: email).first
      if @user.nil?
        Notifier.send "Log In", "Sorry, no registered user with #{email}", 1
        #system("notify-send 'Log In' 'No registered user with #{email}' -t 0")
        arr = all_users_emails.select do |emaill|
            emaill[0] == email[0]
        end
        Notifier.send "Sign In", "Did you mean? \n\t#{arr.join "\n\t"}", 50 unless arr.empty?
        sign_in
      elsif @user.password != password || password == nil
        Notifier.send "Sign In", "Password is not match", 50
        first_page
      else
        my_page
      end
    end

  end

  def list_table
    puts "\n\nActive Lists\n".bold.blue
    tp List.all, :name, :create_time, :user_id
  end

  def change_list_menu
    puts "\nIf you want add list/item first Sign In".blue.underline
    first_page
  end


  def my_page
    Notifier.send "My Page", "Welcome  #{@user.name}", 2000, :info
    #    system("notify-send 'sign In' 'Save user?' -t   0")
    title "My Page"
    case menu("Exit","Show Lists","Show Items")
    when 1
      sign_out
    when 2
      all_lists
      list_settings
    when 3
      all_items
      my_page
    end
  end

  def all_lists
    if List.any?
    puts blue_bold "\nList Table\n"
    print_table "N", "List Name", "User Id", List.all
    else
      puts "No data"
    end
  end

  def all_items
    if Item.any?
    puts "\nItem Table\n".blue.bold
      print_table "Item Name", "List Id", "User Id", @user.items
    else
      puts "No data"
    end
  end

  def list_settings
    title "List Settings"
    case menu "Add list", "Change list", "Delete list", "Back"
    when 1
      add_list
      list_settings
    when 2
      change_list
    when 3
      delete_list
    when 4
    end
  end
    
  def add_list
   name = ask("\nEnter listname: ".blue) 
   while  !List.where(name: name).empty?
     puts "Sorry, there is a list with given name"
   name = ask("\nEnter listname: ".blue) 
    end
   yes_or_no.downcase == 'y' ? @user.add_list(name) :  my_page
  end

  def change_list
    ask("Which one do you want to change?(number)".blue, Integer) {|q| q.in =1..6 }
  end


  def print_table(*head, rows)
    build_func = "build_#{rows.first.class.name.downcase}_row"
    puts "#{Text::Table.new head: head, rows: rows.map {|row| send(build_func, row) }}\n"
  end


  def build_list_row(list)
    number = nil
    List.all.each_with_index do |list, i|
      number = i+1
    build_tb_raw [number, list.name, list.user_id],
                 list.user_id == @user.id ? :red : nil
  end
  end


  def build_item_row(item)
    build_tb_raw [item.name, item.list_id, item.user_id],
                 item.user_id == @user.id ? :red : nil
  end
  def build_tb_raw(cells,color )
    cells.map do |cell|
      {value: cell, cb: color}
    end
  end

  def sign_up
    @user = User.new
    puts "\n#{@under_line}Sign Up#{@under_line}".blue.bold

      name = ask("\nEnter your Name: ".blue) 
      while !validate_presence? name
      name = ask("\nEnter your Name: ".blue) 
      end
      @user.name = name

      surname = ask("Enter your Surname: ".blue)
      while !validate_presence? surname
      surname = ask("\nEnter your Surname: ".blue) 
      end
      @user.surname = surname

      email = ask("Enter your Email: ".blue)
      while !validate_presence? email
      email = ask("\nEnter your Email: ".blue) 
      end
      @user.email = email

      password = ask("Enter your Password: ".blue) {|q| q.echo = "*"}
      while !validate_presence? password
      password = ask("\nEnter your Password: ".blue) {|q| q.echo = "*"} 
      end
      @user.password = password

      confirm = ask("Save account? [Y/N] ".blue) { |yn| yn.limit = 1, yn.validate = /[yn]/i }
      confirm.downcase == 'y' ? @user.save  : first_page
  end

  def all_users_emails
    User.all.map &:email 
  end

  def all_lists_names
    List.all.map &:name
  end

  def validate_presence?(string)
    if string.empty?
      puts "Input your data"
      false
    else
      true
    end
  end

  def menu(*name)
    name.each_with_index do |name,i|
      puts blue_bold "#{i+1}. #{name}"
    end
    answer = ask("Choose ", Integer) {|q| q.in = 1..name.length}
      answer
  end

  def blue_bold(str)
    str.blue.bold
  end

  def yes_or_no
     confirm = ask("Do it? [Y/N] ".blue) { |yn| yn.limit = 1, yn.validate   = /[yn]/i }
     confirm
  end

end





######################################
###############  main ################
$VERBOSE = nil
app = App.new
app.first_page
