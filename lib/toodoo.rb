require "toodoo/version"
require "toodoo/init_db"
require 'highline'
require 'pry'

module Toodoo
  module Models
    class User < ActiveRecord::Base
    end
  end
end

binding.pry
