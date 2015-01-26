class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :list_id
      t.string :name
      t.datetime :due_date
      t.timestamps
      t.boolean :finished
    end
  end

  def self.down
    drop_table :items
  end
end
