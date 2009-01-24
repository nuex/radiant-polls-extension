class MarkAnswersShouldDestroy < ActiveRecord::Migration
  def self.up
    add_column :answers, :should_destroy, :integer
  end

  def self.down
    remove_column :answers, :should_destroy
  end
end
