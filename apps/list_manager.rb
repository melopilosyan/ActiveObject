require_relative "../objects/list.rb"
require_relative "../objects/item.rb"
require_relative "../objects/user.rb"

class ListManager 
  
  attr_accessor :user
  PATH = "../memarMe/memar_user.json"

  def get 
    gets.strip
  end

  def get_answer_in(range)
    while true
      print "=> ".red
      answer = get.to_i
      if range.include? answer
        return answer
      else
        puts "invalid command !!".yellow
      end
    end
  end

  def page_head(*location)
    puts
    line = 0
    location.each_with_index do |section, i|
      if i == (location.length - 1)
        print "#{section}\n".blue
        line += section.length
        break
      end
      print "#{section} ".blue + "/ ".red
      line += (section.length + 3) 
    end
    puts ("-" * line).white    
  end


  def page_menu(list) 
    list.each_with_index do |val, i|
      puts "#{i + 1}. #{val}".white
    end
  end

  def main_page
    page_head :main
    page_menu %W(Signup Login List\ menu)
    case get_answer_in 1..3
      when 1 
        registration
      when 2
        login
      when 3
        list_tab
    end
  end

  def list_tab 
    h =["id", "Name", "User"]
    lists = get_lists(:all)[0]
    l = []
    lists.sort_by! do |list| 
      list.id
    end
    lists.each_with_index do |list, i|
      menu = {id: 0, Name: "", User: ""}
      menu[:id] = i + 1
      menu[:Name] = list.name
      menu[:User] = list.user.name
      l << menu
      end
      List.drow_table(l, h)
      puts "1.back".white
      get_answer_in 1..1
      main_page
       
    end

    def save_user 
      File.write(PATH, self.user.to_json)
    end

    def get_saved_user 
      data = File.read(PATH).strip
      if data.empty?
        nil
      else
        User.from_json(data)
      end
    end

    def login
      page_head :login
      while true
        print "Your login: ".red 
        self.user = User.where(login: get)[0]
        if user.nil? 
          puts "Invalid login !!".yellow
        else
          while true
            print "Your password: ".red
            if user.password == get
              save_user
              user_info
              break
            else
              puts "Invalid password !!".yellow
            end
          end
        end
      end
    end

    def registration
      page_head :registration
      data = {name: "", surname: "", login: "", password: ""}
      data.each do |k, v|
        while true 
          print "#{k}: ".white
          data[k] = get
          break if !data[k].empty?
        end
      end
      self.user = User.create(data)
      puts "you are registred #{data[:name]} !\n".yellow
      user_info
    end

    def user_info
      page_head(user.full_name)
      page_menu %w(Created\ lists Add\ list Edit\ user Delete\ user Logout)
      case get_answer_in 1..5
        when 1
          lists
        when 2
          add_list
        when 3
          user_edit
        when 4
          user_delete
        when 5
          File.write(PATH, "")
          main_page
      end
    end

    def change_msg(name, back, new, l = "") 
      str1 = "your#{l} #{name}".yellow + " (#{back}) ".red
      str2 = "was changed to ".yellow + "(#{new})".red
      puts str1 + str2
    end

    def del_add_msg(event, name) 
      puts "you #{event} list ".yellow + "(#{name})".red
    end


    def user_edit
      page_head user.full_name, :edit
      list = %W(Name Surname Login Password)
      page_menu(list + ["Back"])
      answer = get_answer_in 1..5
      check_edit_user(answer, list)
    end

    def check_edit_user(answer, list)
        if answer == list.length + 1 
          user_info
          return
        end
        page_head user.full_name, :edit, list[answer - 1]
        print "new #{list[answer - 1]}: ".white
        atr = list[answer - 1].to_sym
        back_name = user.send(list[answer - 1])
        new_name = get
        user.update({atr => new_name})
        change_msg(atr, back_name, new_name)
        user_edit
    end

    def user_delete
      user.lists.each do |list| 
        list.items.each do |item| 
          item.delete
        end
        list.delete
      end
      user.delete
      File.write(PATH, "")
      main_page
    end
    
    def get_lists(castumer)
      case castumer
      when :all
        lists = List.all
        lists
      when :user
        lists = user.lists.sort_by do |list| 
          list.id
        end

      when :other
        lists = List.all.select do |list|
          no_contain = true
          list.items.each do |item| 
            if item.user_id == user.id
              no_contain = false
              break
            end
          end
          list.user.id != user.id && (list.items.empty? || no_contain)
        end
      end
      menu = lists.map do |list| 
        list.name
      end
      [lists, menu]
    end
    
    def lists
      page_head user.full_name, "created lists"
      l = get_lists(:all)
      l[1].each_with_index do |list, i| 
        l[1][i] = list + "(#{l[0][i].user.name})"
      end
      size = l[1].length + 1
      page_menu l[1] + ["Back"]
      answer = get_answer_in 1..size
      user_info if answer == size
      checked_list(l[0][answer-1])
    end

    def checked_list(list)
      page_head user.full_name, :lists, list.name
      my_list(list) if list.user_id == user.id 
      lis = has_item?(list)
        if lis 
          menu = lis[1] + ["Contain list", "Back"]
        else
          menu = ["Add item", "Contain list", "Back"]
        end
        page_menu menu
        size = menu.length
        answer = get_answer_in 1..size
        case answer 
        when 1
          
          if size == 3
            add_item(list)
          else
            edit_item(list, lis[0])
          end
        when 2
          if size == 3 
            contain_list(list)
          else
            name = lis[0].name
            lis[0].delete
            puts "you deleted item ".yellow + "(#{name})".red
            checked_list(list)
          end
        when 3 
          if size == 3 
            lists
          else
            contain_list(list)
          end
        when 4
          lists
        end
    end

    def my_list(list)
      menu = %W(Edit\ list Delete\ list)
      has = has_item?(list)
      if has 
        menu += has[1]
      else
        menu += ["Add item"]
      end
      menu += ["Contain list", "Back"]
      page_menu menu
      size = menu.length
      answer = get_answer_in 1..size
      case_answer(answer, size, list, has)
    end

    def case_answer(answer, size, list, has)
      case answer 
      when 1
        edit_list(list)
      when 2
         delete_list(list)
      when 3
        if size == 5 
          add_item(list)
        else
          edit_item(list, has[0])
        end
      when 4
        if size == 5 
          contain_list(list)
        else
          has[0].delete
          puts "you delete item ".yellow + "#{has[0].name}".red
          checked_list(list)
        end
      when 5
        if size == 5 
          lists
        else
          contain_list(list)
        end
       when 6
         lists
      end
    end

    def has_item?(list) 
      has = false
      i = nil
      menu = []
      name = ""
      list.items.each do |item| 
        if item.user_id == user.id 
          has = true
          i = item
          name = i.name
        end
      end
      if has 
        menu += ["Edit item(#{name})", "Delete item(#{name})"]
        [i, menu]
      else
        nil
      end
    end

    def add_item(list)
      page_head user.full_name, :lists, list.name, :add_item
      data = {name: ""}
      print "name: ".white
      data[:name] = get
      item = Item.new(data)
      item.user_id = user.id
      list.add_item(item)
      puts "you add item ".yellow + "#{item.name}".red + " in list ".yellow + "#{list.name}".red + " whitch created ".yellow +  "#{list.user.name}".red
      checked_list(list)
    end

    def add_list
      page_head user.full_name, :lists, :add
      data = {name: ""}
      data.each do |k, v|
        while true 
          print "#{k}: ".white
          data[k] = get
          break if !data[k].empty?
        end
      end
      list = List.new(data)
      user.add_list(list)
      del_add_msg(:created, list.name)
      user_info
    end

    def delete_list(list)
      page_head user.full_name, :lists, list.name, :delete
      list.items.each do |item| 
        item.delete
      end
      list.delete
      del_add_msg(:deleted, list.name)
      checked_list(list)
    end

    def edit_list(list) 
      page_head user.full_name, :lists, list.name, :edit
      atr = :name
      back_name = list.send(atr)
      new_name = ""
      while true
        print "new #{atr}: ".white
        new_name = get
        break unless new_name.empty?
      end
      list.update({atr => new_name})
      change_msg(atr, back_name, new_name, " list")
      checked_list(list)
    end

    def edit_item(list, item) 
      page_head user.full_name, :lists, list.name, item.name, :edit
      atr = :name
      back_name = list.send(atr)
      new_name = ""
      while true
        print "new #{atr}: ".white
        new_name = get
        break unless new_name.empty?
      end
      item.update({atr => new_name})
      change_msg(atr, back_name, new_name, " item")
      checked_list(list)
    end

  def contain_list(list)
    page_head user.full_name, :lists, list.name, :contain
    h = ["id", "Name", "User"]
    items = []
    l = list.items
    l.sort_by! do |item| 
      item.id
    end
    l.each_with_index do |item, i|
      menu = {id: 0, Name: "", User: ""}
      menu[:id] = i + 1
      menu[:Name] = item.name
      menu[:User] = item.user.name
    items << menu
    end
    Item.drow_table(items, h)
    puts "1. Back".white
    get_answer_in 1..1
    checked_list(list)
  end

  def self.start 
    l = new
    l.user = l.get_saved_user
    if l.user
      l.user_info 
    else
      l.main_page
    end
  end

end
