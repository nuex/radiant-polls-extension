class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.string :title
      t.integer :response_count
    end
  end

  def self.down
    drop_table :polls
  end
end
