class CreateSlicegroups < ActiveRecord::Migration
  def self.up
    create_table :slicegroups do |t|
      t.column :name, :string, :limit => 100, :default => "", :null => false
      t.column :description, :string, :default => "", :null => false
    end

    add_index :slicegroups, :name, :unique => true
    Slicegroup.create(:name => "General Slices", :description => "Default Slice Group")
  end

  def self.down
    remove_index :slicegroups, :name
    drop_table :slicegroups
  end
end
