class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.column :slice_id, :integer, :default => 0, :null => false
      t.column :node_id, :integer, :default => 0, :null => false
      t.column :dayAndTime, :datetime, :null => false
      t.column :cpu, :float, :default => 0.0, :null => false
      t.column :avgSendBW, :float, :default => 0.0, :null => false
      t.column :avgRecvBW, :float, :default => 0.0, :null => false
      t.column :sampleInterval, :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :samples
  end
end
