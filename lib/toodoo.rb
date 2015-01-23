require "toodoo/version"
require "toodoo/init_db"
require 'highline/import'
require 'pry'

module Toodoo
  module Models
    class User < ActiveRecord::Base
    end
  end
end

class TooDooApp
  def initialize
    @user = nil
    @todos = nil
    @todo_item = nil
  end

  def new_user
    puts "Okay. Let's create a new user."
    puts "What user name would you like?"
    name = gets.chomp
    new_user = Toodoo::Models::User.create(:name => name)
    @user = new_user
    puts "We've created your account and logged you in. Thanks #{@user.name}!"
  end

  def login
    choose do |menu|
      Toodoo::Models::User.find_each do |u|
        menu.choice(u.id.to_sym, "Login as #{u.name}.") { @user = u }
      end

      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @user = nil
      end
    end
  end

  def pick_todo_lists
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
        unless @todos
          menu.choice(:new_list, "Create a new todo list.") { new_todo_list }
          menu.choice(:pick_list, "Work on an existing list.") { pick_todo_list }
        end

        # Let's work on some todos!

        menu.choice(:quit, "Quit!") { exit }
      end
    end
  end
end

binding.pry

todos = TooDooApp.new
todos.run
