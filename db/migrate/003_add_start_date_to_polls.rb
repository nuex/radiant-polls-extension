class AddStartDateToPolls < ActiveRecord::Migration
  def self.up
    add_column :polls, :start_date, :date
  end

  def self.down
    remove_column :polls, :start_date
  end
end
