require "bundler/gem_tasks"
require_relative "lib/toodoo/init_db"

namespace :db do
  desc "Run migrations"
  task :migrate do
    version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    ActiveRecord::Migrator.migrate('db/migrate', version)
  end
end
