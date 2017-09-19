require "colorize"
require "highline/import"
require "table_print"
require "text-table"
require "json"

require_relative "objects/user"
require_relative "objects/item"
require_relative "objects/list"
require_relative "helpers/notifier"


class App

  def initialize 
    if File.exist? "data/session.json"
      hash = JSON.parse  File.read "data/session.json"
      if !hash.empty?
        @user = User.search_by_id hash["id"]
        puts @user.to_s
        my_page
      end
    else
      File.write("data/session.json", "{}")
    end
  end

  def first_page
    title "List Manager"
    case menu  "Sign In", "Sign Up", "Active Lists", "Exit"
    when 1 
      sign_in
    when 2
      sign_up
      my_page
    when 3
      list_table
      change_list_menu
    when 4
      exit
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
      say("\nFor Sign In first Sign Up").blue
      yes_or_no.downcase == 'y' ? sign_up : first_page
    else
      email = ask("\nEnter your Email: ".blue)
      password = ask("Enter your Password: ".blue) {|q| q.echo = "*"}
      @user = User.where(email: email).first
      if @user.nil?
        Notifier.send "Log In", "Sorry, no registered user with #{email}", 1
        arr = all_users_emails.select do |emaill|
          emaill[0] == email[0]
        end
        Notifier.send "Sign In", "Did you mean? \n\t#{arr.join "\n\t"}", 50 unless arr.empty?
        first_page
      elsif @user.password != password || password == nil
        Notifier.send "Sign In", "Password is not match", 50
        first_page
      else
         confirm = yes_or_no "Remember email and password?"
        if confirm  == 'y'
          save_user_in_session 
        end
    Notifier.send "My Page", "Welcome  #{@user.name}", 2000, :info
        my_page
      end
    end

  end

  def list_table
    puts "\n\nActive Lists\n".bold.blue
    tp List.all, :name, :create_time, :user_id
  end

  def change_list_menu
    puts "\nIf you want add list/item first Sign In".blue
    first_page
  end

  def my_page
    title "My Page"
    l = 60 - 2 - (@user.name.length + @user.surname.length)
    puts "#{" " * l}#{@user.name} #{@user.surname}".blue
    case menu("Lists", "My info", "Edit","Log out", "Exit")
    when 1
      all_lists
    when 2
      my_info
      my_page
    when 3
      edit_user
      my_page
    when 4
      sign_out
    when 5
      exit
    end
  end

    def my_info
      title "My Info"
  print <<EOF
Name: #{@user.name}
Surname: #{@user.surname}
Email: #{@user.email}\n
EOF
    end





  def edit_user
    my_info
    title "Edit your info"
    name = ask("\nEnter your Name: ".blue) 
    @user.name = name unless name.empty?

    surname = ask("Enter your Surname: ".blue)
    @user.surname = surname unless surname.empty?

    email = ask("Enter your Email: ".blue)
    @user.email = email unless email.empty?

    password = ask("Enter your Password: ".blue) {|q| q.echo = "*"}
    @user.password = password unless password.empty?

    confirm = yes_or_no "Save changes?"
    if confirm == 'y'
      @user.save 
    end
    my_info
  end

  def save_user_in_session
    hash = JSON.parse File.read "data/session.json"
    hash[:id] = @user.id
    File.write("data/session.json", hash.to_json)
  end

  def delete_user_in_session
    hash = JSON.parse File.read "data/session.json"
    hash.delete"id"
    File.write("data/session.json", hash.to_json)
  end

  def all_lists
    puts "\n#{@user.name}/lists".blue
    if List.any?
      puts blue_bold "\nList Table\n"
      print_table "N", "List Name", "User Name", List.all 
      case menu "Add list", "Select list", "Log out", "Exit"
      when 1
        add_list
      when 2
      given_id = ask("Which one do you want select?(N)".blue, Integer) {|q| q.in =1..List.all.length }
      @list = List.search_by_id given_id
      puts "\n#{@user.name}/lists/#{@list.name}".blue
      list_settings
      when 3
        sign_out
      when 4
        exit
      end
    elsif @user.lists.empty?
      puts "\nNo lists\n".blue
      case menu "Add list", "Back", "Exit", "Log out"
      when 1
        add_list
        my_page
      when 2
        my_page
      when 3
        exit
      when 4
        sign_out
      end
    end
  end

  def all_items
    puts "#{@user.name}/lists/#{@list.name}/items"
    if Item.any?
      puts blue_bold "\nItem Table\n"
      print_table "Item name", "User Name", "List name", @list.items
    else
      puts "No items"
    end
  end

  def list_settings
    title "List Settings"
    if !@list.items.empty? && @list.user_id == @user.id && !@user.items.empty?
      case menu "Items","Edit List","Delete list", "Edit Item","Delete Item","Back", "Exit", "Log out"
      when 1
        all_items
        list_settings
      when 2
        change_list
        list_settings
      when 3
        delete_list
        list_settings
      when 4
        change_item
        list_settings
      when 5
        delete_item
        list_settings
      when 6
        all_items
      when 7
        exit
      when 8
        sign_out
      end
    elsif @user.lists.empty?
      case menu "Add list", "Back", "Exit", "Log out"
      when 1
        add_list
      when 2
        my_page
      when 3
        exit
      when 4
        sign_out
      end
    elsif @user.id != @list.id && !@list.items.empty?
      case menu "Items","Edit item","Delete item", "Back", "Exit", "Log out"
      when 1
        all_items
        my_page
      when 2
        change_item
        my_page
      when 3
        delete_item
        my_page
      when 4
        my_page
      when 5
        exit
      when 6
        sign_out
      end
    elsif @user.id != @list.id
      case menu "Add Item", "Back", "Exit", "Log out"
      when 1
        add_item
        my_page
      when 2
        my_page
      when 3
        exit
      when 4
        sign_out
      end
    else  
      case menu "Add Item","Edit", "Delete", "Back","Exit","Log out"
      when 1
        add_item
        list_settings
      when 2
        list_settings
        my_page
      when 3
        delete_list
        list_settings
      when 4
        my_page
      when 5 
        exit
      when 6
        sign_out
      end
    end

  end

  def add_list
    name = ask("\nEnter listname: ".blue) 
    while  !List.where(name: name).empty?
      puts "Sorry, there is a list with given name"
      name = ask("\nEnter listname: ".blue) 
    end
    if yes_or_no "Save list?" == 'y' 
      @user.add_list(name)
    end
      my_page
  end

  def change_list
    @list.name = ask("\nEnter new listname: ")
    yes_or_no "Save changes?" == 'y' ? @list.save : list_settings
  end

  def delete_list
    yes_or_no "Are you sure?" == 'y' ? @list.delete : list_settings
  end

  def show_list_items
    all_lists
    if List.any? 
      list = List.search_by_id ask("Number of list".blue, Integer)
      if !list.items.empty?
        print_table "Item Name", "User name", "List name", list.items
      else
        puts "\nNo Item\n".blue
      end
    end
  end

  def add_item
    if !@user.lists.empty?
    item_name = ask("Item name:  ".blue)
    confirm = yes_or_no "Save item?"
    confirm  == 'y' ? @user.add_item(item_name ,@list.id) :  all_lists
  end
  end

  def change_item
    item = Item.where(list_id: @list.id)[0]
    item.name =  ask("Input new name:  ".blue)
    confirm = yes_or_no"Save changes?"
    confirm == 'y' ? item.save :  list_settings
  end

  def delete_item
    item = Item.where(list_id: @list.id, user_id: @user.id)[0]
    confirm = yes_or_no"Are you sure?"
    confirm == 'y' ? item.delete : list_settings
  end

  def print_table(*head, rows)
    build_func = "build_#{rows.first.class.name.downcase}_row"
    puts "#{Text::Table.new head: head, rows: rows.map {|row| send(build_func, row) }}\n"
  end

  def build_list_row(list)
    build_tb_raw [list.id, list.name, User.search_by_id(list.user_id).name],
      list.user_id == @user.id ? :red : nil
  end

  def build_item_row(item)
    build_tb_raw [item.name, User.search_by_id(item.user_id).name, List.search_by_id(item.list_id).name],
      item.user_id == @user.id ? :red : nil
  end

  def build_tb_raw(cells,color )
    cells.map do |cell|
      {value: cell, cb: color}
    end
  end

  def sign_up
    title "Sign Up"
    @user = User.new

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

    confirm = yes_or_no"Save account?"
    confirm == 'y' ? @user.save  : first_page
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

  def yes_or_no(question)
    confirm = ask("#{question} [Y/N] ".blue) { |yn| yn.limit = 1, yn.validate   = /[yn]/i }
    confirm.downcase
  end

  def sign_out
    delete_user_in_session
    puts "Bye".blue
  end

end





######################################
###############  main ################
$VERBOSE = nil
app = App.new
app.first_page
