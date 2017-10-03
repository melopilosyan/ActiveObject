require_relative "../objects/user.rb"
require_relative "../objects/post.rb"
require 'colorize'

class App

  def get 
    gets.strip
  end

  def get_int 
    get.to_i
  end

  def get_answer_in(range)
    while true
      print "check: ".red
      answer = get_int
      if range.include? answer
        return answer
      else
        puts "invalid command !!".yellow
      end
    end
  end

  def page_head(location)
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


  def page_menu(*list) 
    list.each_with_index do |val, i|
      puts "#{i + 1}.#{val}".white
    end
  end

  def user_posts(user) 
    page_head([user.full_name, "posts"])
    page_menu(:add, :delete, :edit, :list, :back)
    case get_answer_in(1..5)
      when 1 
        add_post(user)
      when 2
        delete_post(user)
      when 3
        edit_post(user)
      when 4
        posts_list(user)
      when 5
        user_info(user)
    end
  end

  def add_post(user)
    page_head %W(#{user.full_name} posts add)
    data = {title: "", description: ""}
    data.each do |k, v|
      while true 
        print "#{k}: ".white
        data[k] = get
        break if !data[k].empty?
      end
    end
    user.add_post(Post.new(data))
    puts "you registred new post !\n".yellow
    user_posts user
  end

  def posts_table(user) 
    posts = user.posts
    h = ["count", "id", "title", "description", "user_id"]
    hash = {count: 0}
    posts.map! do |post|
      post.to_hash   
    end
     posts.each_with_index do |post, i| 
      hash[:count] = i + 1
      posts[i] = hash.merge(post)
    end
    Post.drow_table(posts, h)
  end

  def delete_post(user) 
    page_head %W(#{user.full_name} posts delete)
    posts_table(user)
    posts = user.posts
    size = user.posts.length + 1
    puts "#{size}.back".white
    a = get_answer_in(1..size)
    if a == size
      user_posts(user)
      return
    end
    posts[a-1].delete
    puts "you delete post #{a} !!".yellow
    delete_post(user)
  end

  def edit_post(user) 
    page_head %W(#{user.full_name} posts edit)
    posts_table(user)
    posts = user.posts
    size = user.posts.length + 1
    puts "#{size}.back".white
    a = get_answer_in(1..size)
    if a == size
      user_posts(user)
      return
    end
    e_post = posts[a-1]
    post_edit_list(a, e_post, user)
  end

  def post_edit_list(a, post, user) 
    page_head([user.full_name, "edit"])
    page_menu(:title, :description, :back)
    ans_list = %W(title description)
    ans = get_answer_in(1..3)
    check_edit_post(a, ans, ans_list, post, user)
  end

  def check_edit_post(a, us_ans, list, post, user)
    page_head([user.full_name, "posts", "edit", a.to_s])
    print "new #{list[us_ans - 1]}: ".white
    atr = list[us_ans - 1].to_sym
    l = post.send(list[us_ans - 1])
    n = get
    post.update({atr => n})
    puts "your post #{atr}(#{l}) was changed to #{n} !!".yellow
    edit_post(user)
  end

  def posts_list(user)
    page_head %W(#{user.full_name} posts list)
    posts_table(user)
    puts "1.back".white
    get_answer_in(1..1)
    user_posts(user)
  end

  def user_edit(user) 
    page_head([user.full_name, "edit"])
    page_menu(:name, :surname, :password, :back)
    ans_list = %W(name surname password)
    ans = get_answer_in(1..4)
    check_edit_user(ans, ans_list, user)
  end

  def check_edit_user(us_ans, list, user)
      if us_ans == list.length + 1 
        user_info(user)
        return
      end
      page_head([user.full_name, "edit", list[us_ans - 1]])
      print "new #{list[us_ans - 1]}: ".white
      atr = list[us_ans - 1].to_sym
      l = user.send(list[us_ans - 1])
      n = get
      user.update({atr => n})
      puts "your #{atr}(#{l}) was changed to #{n} !!".yellow
      user_edit(user)
  end

  def user_info(o) 
    page_head([o.full_name])
    page_menu(:posts, :edit, :back)
    case get_answer_in(1..3)
      when 1
        user_posts(o)
      when 2
        user_edit(o)
      when 3
        login
    end
  end
   
  def login
    page_head(["login"])
    while true
      print "your login: ".red 
      u = User.where(login: get)[0]
      if u.nil? 
        puts "invalid login !!".yellow
      else
        while true
          print "your password: ".red
          if u.password == get 
            user_info(u)
            break
          else
            puts "invalid password !!".yellow
          end
        end
      end
    end
  end

  def registration
    page_head(["registration"])
    data = {name: "", surname: "", login: "", password: ""}
    data.each do |k, v|
      while true 
        print "#{k}: ".colorize(:white)
        data[k] = get
        break if !data[k].empty?
      end
    end
    u = User.create(data)
    puts "you are registred #{data[:name]} !\n".yellow
    user_info(u)
  end

  def main_page
    page_head(["main page"])
    page_menu(:registration, :login, :back)
    case get_answer_in(1..3)
      when 1 
        registration
      when 2
        login
      when 3
        return
    end
  end

end

a = App.new
a.main_page
