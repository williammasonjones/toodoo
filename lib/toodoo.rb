require "toodoo/version"
require "toodoo/init_db"
require 'highline/import'
require 'pry'

module Toodoo
  class User < ActiveRecord::Base
    has_many :lists
  end

  class List < ActiveRecord::Base
    belongs_to :user
    has_many :items
  end

  class Item < ActiveRecord::Base
    belongs_to :list
  end

end

class TooDooApp
  def initialize
    @user = nil
    @todos = nil
    @show_done = nil
  end

  def new_user
    say("Creating a new user:")
    name = ask("Username?") { |q| q.validate = /\A\w+\Z/ }
    @user = Toodoo::User.create(:name => name)
    say("We've created your account and logged you in. Thanks #{@user.name}!")
  end

  def login
    choose do |menu|
      menu.prompt = "Please choose an account: "

      Toodoo::User.find_each do |u|
        menu.choice(u.name, "Login as #{u.name}.") { @user = u }
      end

      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @user = nil
      end
    end
  end

  def delete_user
    choices = 'yn'
    delete = ask("Are you *sure* you want to stop using TooDoo?") do |q|
      q.validate =/\A[#{choices}]\Z/
      q.character = true
      q.confirm = true
    end
    if delete == 'y'
      @user.destroy
      @user = nil
    end
  end

  # Creates a new todo list
  # Creates the list in the db
  def new_todo_list
    say("Create a new todo list:")
    title = ask("Please enter a name for your list"){ |q| q.validate = /\A\w+\z/ }
    @todos = Toodoo::List.create(:title => title, :user_id => user.id)
    say("#{user.name}, your new list has successfully been created!")
  end

  # Gets todo lists for the user
  # Selects list
  def pick_todo_list
    choose do |menu|
      menu.prompt = "Please select a list:"
        Toodoo::List.where(:user_id => user_id).find_each do |l|
          menu.choice(l.title, "Select the #{l.title} todo list") {@todos = l}
      end
      menu.choice(:back, "Just kidding, back to the main menu!") do
        say "You got it!"
        @todos = nil
      end
    end
  end

  # Confirm list to be deleted
  # Destroy list & set @todos to nil
  def delete_todo_list
    choose do |menu|
      menu.prompt = "Please select a list to delete"
        Toodoo::List.where(:user_id => user_id).find_each do |l|
          menu.choice(l.title, "Select the #{l.title} todo list") {@todos = l}
      end
    end
    choices = 'yn'
    delete = ask("This list will now be deleted. Are you sure?") do |q|
      q.validate = /A\[#{choices}]\Z/
      q.character = true
      q.confirm = true
    end
    if delete == 'y'
      @todos.destroy
      @todos = nil
    end
  end

  # Creates a new task(item) on todo list.
  def new_task
    say("Create a new todo item:")
    input = ask("Item name?")
    Toodoo::Item.create{:name => input, :finished => false, :list_id => list.id}
  end

  ## NOTE: For the next 3 methods, make sure the change is saved to the database.
  def mark_done
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should update the todo to be completed.
    choose do |menu|
      menu.prompt = "Yay! You completed a task!"
      Toodoo::Item.where(:list_id => @todos.id, :completed => false).each do |i|
        menu.choice(i.name, "Pick the #{i.name} item.") {i.update(:completed => true)}
        i.save
      end
      menu.choice(:back)
    end
  end

  def change_due_date
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should update the due date for the todo. You probably want to use
    # `ask("foo", Date)` here.
  end

  def edit_task
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should change the name of the todo.
  end

  def show_overdue
    # TODO: This should print a sorted list of todos with a due date *older*
    # than `Date.now`. They should be formatted as follows:
    # "Date -- Eat a Cookie"
    # "Older Date -- Play with Puppies"
  end

  def run
    puts "Welcome to your personal TooDoo app."
    loop do
      choose do |menu|
        #menu.layout = :menu_only
        #menu.shell = true

        # Are we logged in yet?
        unless @user
          menu.choice(:new_user, "Create a new user.") { new_user }
          menu.choice(:login, "Login with an existing account.") { login }
        end

        # We're logged in. Do we have a todo list to work on?
        if @user && !@todos
          menu.choice(:delete_account, "Delete the current user account.") { delete_user }
          menu.choice(:new_list, "Create a new todo list.") { new_todo_list }
          menu.choice(:pick_list, "Work on an existing list.") { pick_todo_list }
          menu.choice(:remove_list, "Delete a todo list.") { delete_todo_list }
        end

        # Let's work on some todos!
        if @todos
          menu.choice(:new_task, "Add a new task.") { new_task }
          menu.choice(:mark_done, "Mark a task finished.") { mark_done }
          menu.choice(:move_date, "Change a task's due date.") { change_due_date }
          menu.choice(:edit_task, "Update a task's description.") { edit_task }
          menu.choice(:show_done, "Toggle display of tasks you've finished.") { @show_done = !!@show_done }
          menu.choice(:show_overdue, "Show a list of task's that are overdue, oldest first.") { show_overdue }
          menu.choice(:back, "Go work on another Toodoo list!") do
            say "You got it!"
            @todos = nil
          end
        end

        menu.choice(:quit, "Quit!") { exit }
      end
    end
  end
end

#binding.pry

todos = TooDooApp.new
todos.run
