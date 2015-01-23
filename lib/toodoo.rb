require "toodoo/version"
require "toodoo/init_db"
require 'highline/import'
require 'pry'

module Toodoo
  class User < ActiveRecord::Base
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
    new_user = Toodoo::User.create(:name => name)
    @user = new_user
    say("We've created your account and logged you in. Thanks #{@user.name}!")
  end

  def login
    choose do |menu|
      Toodoo::User.find_each do |u|
        menu.choice(u.id.to_sym, "Login as #{u.name}.") { @user = u }
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

  def new_todo_list
    # TODO: This should create a new todo list by getting input from the user.
    # Primarily, it should have a title and user_id. This method should save
    # the new todo list in the database and set @todos to the new list.
  end

  def pick_todo_list
    choose do |menu|
      # TODO: Insert code to get the todo lists for the logged in user (@user).
      # Iterate over them and add a menu.choice line as seen under the login method's
      # find_each call. The result should set @todos to the todo list retrieved from
      # the database.

      menu.choice(:back, "Just kidding, back to the main menu!") do
        say "You got it!"
        @todos = nil
      end
    end
  end

  def delete_todo_list

  end

  def new_task
  end

  def mark_done
  end

  def change_due_date
  end

  def edit_task
  end

  def show_overdue
  end

  def run
    puts "Welcome to your personal TooDoo app."
    loop do
      choose do |menu|
        menu.layout = :menu_only
        menu.shell = true

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

todos = TooDooApp.new
todos.run
