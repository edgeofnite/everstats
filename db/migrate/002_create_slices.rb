class CreateSlices < ActiveRecord::Migration
  def self.up
    create_table :slices do |t|
      t.column :name, :string, :default => "", :null => false
      t.column :slicegroup_id, :integer, :default => 3, :null => false
    end
    
    add_index :slices, :name, :unique => true
    end

  def self.down
    remove_index :slices, :name
    drop_table :slices
  end
end
