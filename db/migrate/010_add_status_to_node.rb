class AddStatusToNode < ActiveRecord::Migration
  def self.up
	add_column :nodes, :online, :boolean, :default => true
  end

  def self.down
	remove_column :nodes, :online
  end
end
