class CreateDayusages < ActiveRecord::Migration

  def self.up
    create_table :dayusages do |t|
      t.column :slice_id, :integer, :default => 0, :null => false
      t.column :node_id, :integer, :default => 0, :null => false
      t.column :day, :date, :null => false
      t.column :total_activity_minutes, :integer, :default => 0, :null => false
      t.column :avg_cpu, :float, :default => 0.0, :null => false
      t.column :avg_send_BW, :float, :default => 0.0, :null => false
      t.column :avg_recv_BW, :float, :default => 0.0, :null => false
    end
  end

  def self.down
    drop_table :dayusages
  end
end
