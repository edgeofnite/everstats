class AddAllFieldsToSamples < ActiveRecord::Migration
  def self.up
	add_column :samples, :pctmem, :float, :default => 0.0
	add_column :samples, :phymem, :integer, :default => 0
	add_column :samples, :virmem, :integer, :default => 0
	add_column :samples, :procs, :integer, :default => 0
	add_column :samples, :runprocs, :integer, :default => 0
  end

  def self.down
	remove_column :samples, :pctmem
	remove_column :samples, :phymem
	remove_column :samples, :virmem
	remove_column :samples, :procs
	remove_column :samples, :runprocs
  end
end
