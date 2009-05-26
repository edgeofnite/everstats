class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.column :hostname, :string, :limit => 100, :default => "", :null => false
      t.column :primaryipaddress, :string, :limit => 100, :default => "", :null => false
    end

    add_index :nodes, ["hostname", "primaryipaddress"], :name => "hostname", :unique => true
  end

  def self.down
    remove_index :nodes, :name => "hostname"
    drop_table :nodes
  end
end
