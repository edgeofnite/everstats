class ExtendDayusages < ActiveRecord::Migration
  def self.up
    add_column :dayusages, :total_cpu, :float, { :null => false, :default => 0 }
    add_column :dayusages, :total_send_BW, :float, { :null => false, :default => 0 }
    add_column :dayusages, :total_recv_BW, :float, { :null => false, :default => 0 }
    add_column :dayusages, :max_cpu, :float, { :null => false, :default => 0 }
    add_column :dayusages, :max_send_BW, :float, { :null => false, :default => 0 }
    add_column :dayusages, :max_recv_BW, :float, { :null => false, :default => 0 }
    add_column :dayusages, :number_of_samples, :integer, { :null => false, :default => 0 }
    add_column :dayusages, :last_update, :datetime, { :null => false, :default => '2009-01-01 00:00:00' }	
    add_index :dayusages, :last_update
  end

  def self.down
    remove_index :dayusages, :last_update
    remove_column :dayusages, :total_cpu
    remove_column :dayusages, :total_send_BW
    remove_column :dayusages, :total_recv_BW
    remove_column :dayusages, :max_cpu
    remove_column :dayusages, :max_send_BW
    remove_column :dayusages, :max_recv_BW
    remove_column :dayusages, :number_of_samples
    remove_column :dayusages, :last_update
  end
end
