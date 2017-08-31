require_relative "objects/post"
require_relative "objects/user"

class App 

  def first_page
    puts "\nInput 1 for LOGIN, 2 for REGISTRATION, 0 for EXIT"
    case gets_i
    when 0
      log_out
    when 1
      log_in
      second_page
    when 2
      registration
      first_page
    else
      first_page
    end
  end

  def second_page
    puts "1: See my INFO, 2: POSTS, 3: EDIT, 4: EXIT"
    case gets_i
    when 1
      my_info
    second_page
    when 2
      post_settings
    when 3
      edit_user
      second_page
    when 4 
      log_out
    else
      second_page
    end
  end


  def log_in
    print "Email: "
    email = gets_chomp
    print "Password: "
    password = gets_chomp
    @user =  User.where(email: email).first
    if @user.nil? 
      puts "Sorry, no registered user with given email"
      log_in
    elsif @user.password != password
      puts "Password is not match"
      log_in
    else
      puts "        Welcome #{@user.name}\n"
    end
  end

  def registration
    user = User.new
    print "Name: "
    user.name = gets_chomp
    print "Surname: "
    user.surname = gets_chomp
    print "Age: "
    user.age = gets_chomp.to_i
    print "Email: "
    user.email = gets_chomp
    print "Password: "
    user.password = gets_chomp
    print "Submit your data[y/n]? "
    if yes
      user.save
      puts "User is saved!!!"
    end
  end

  def my_info
      print <<EOF
  Name: #{@user.name}
  Surname: #{@user.surname}
  Age: #{@user.age}
  Email: #{@user.email}\n
EOF
  end

  def edit_user
    puts "If you dont want change press ENTER "
    print "Name: "
    name = gets_chomp
    @user.name = name  unless name.empty?
    print "surname: "
    surname = gets_chomp
    @user.surname = surname unless surname.empty?
    print "age: "
    age = gets_chomp
    @user.age = age unless age.empty?
    print "email: "
    email = gets_chomp
    @user.email = email unless email.empty?
    print "password: "
    password = gets_chomp
    @user.password = password unless password.empty?
      print "Save changes[y/n]? "
      if yes
        @user.save
        puts "Changes are saved!!!\n"
      end
  end

  def post_settings
    puts "       \n Post settings"
    puts "1: add post, 2: delete post, 3: edit post, 4: list posts, 5: back"
    case gets_i
    when 1
      add_post
      post_settings
    when 2
      delete_post
      post_settings
    when 3
      edit_post
      post_settings
    when 4
      list_posts
      post_settings
    when 5
      second_page
  end
  end
    
  def add_post
      post = Post.new
      post.user_id = @user.id
      print "Post title: "
      post.title = gets_chomp
      print "Post description: "
      post.description = gets_chomp
      print "Submit your data[y/n]? "
      if yes
        post.save
        puts "Post is saved!!!\n"
      end
  end

  def list_posts
      puts "\nYour posts: "
      posts =  @user.posts
      posts.each_with_index do |post,i|
          puts "#{i+1}. Post title: #{post.title}, description: #{post.description}"
      end
  end

  def delete_post
    posts = list_posts
      puts "Which one do you want to delete?(Number of post)"
      answer = gets_i
      if answer > posts.length
        puts "\nArong number of post, choose right number"
        delete_post
      else
        print "Are you sure[y/n]? "
        if yes
          posts[answer-1].delete
          puts "Post is deleted!!!\n"
        end
      end
  end

  def edit_post
    posts = list_posts
    puts "Which one do you want to change?"
    answer = gets_i
    if answer > posts.length
      puts "\nArong number of post,choose rigth number"
      edit_post
    else
      print "Title: "
      title = gets_chomp
      posts[answer-1].title = title unless title.empty?
      print "Description: "
      description = gets_chomp
      posts[answer-1].description = description unless description.empty?
      print "Save changes[y/n]? "
      if yes
        posts[answer-1].save
        puts "Changes are saved!!!\n"
      end
    end
  end

  def gets_chomp
    gets.chomp    
  end

  def gets_i
    gets_chomp.to_i
  end

  def yes
    gets_chomp == "y"
  end

  def log_out
    puts "\nBye"
  end

end


app = App.new
app.first_page



