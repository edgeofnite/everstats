class AddAllFieldsToDayusages < ActiveRecord::Migration
  def self.up
	add_column :dayusages, :avg_pctmem, :float, :default => 0.0
	add_column :dayusages, :total_pctmem, :float, :default => 0.0
	add_column :dayusages, :max_pctmem, :float, :default => 0.0

	add_column :dayusages, :avg_phymem, :float, :default => 0.0
	add_column :dayusages, :total_phymem, :integer, :default => 0
	add_column :dayusages, :max_phymem, :integer, :default => 0

	add_column :dayusages, :avg_virmem, :float, :default => 0.0
	add_column :dayusages, :total_virmem, :integer, :default => 0
	add_column :dayusages, :max_virmem, :integer, :default => 0

	add_column :dayusages, :avg_procs, :float, :default => 0.0
	add_column :dayusages, :total_procs, :integer, :default => 0
	add_column :dayusages, :max_procs, :integer, :default => 0

	add_column :dayusages, :avg_runprocs, :float, :default => 0.0
	add_column :dayusages, :total_runprocs, :integer, :default => 0
	add_column :dayusages, :max_runprocs, :integer, :default => 0
  end

  def self.down
	remove_column :dayusages, :avg_pctmem
	remove_column :dayusages, :total_pctmem
	remove_column :dayusages, :max_pctmem

	remove_column :dayusages, :avg_phymem
	remove_column :dayusages, :total_phymem
	remove_column :dayusages, :max_phymem

	remove_column :dayusages, :avg_virmem
	remove_column :dayusages, :total_virmem
	remove_column :dayusages, :max_virmem

	remove_column :dayusages, :avg_procs
	remove_column :dayusages, :total_procs
	remove_column :dayusages, :max_procs

	remove_column :dayusages, :avg_runprocs
	remove_column :dayusages, :total_runprocs
	remove_column :dayusages, :max_runprocs
  end
end
