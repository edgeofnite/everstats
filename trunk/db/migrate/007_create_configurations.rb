class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.column :config_key, :string, :limit => 20, :default => "", :null => false
      t.column :config_value, :string, :default => "", :null => false
    end

    add_index :configurations, :config_key, :unique => true

    Configuration.create(:config_key => "samples_interval", :config_value => "60")
    Configuration.create(:config_key => "days_to_keep_samples", :config_value =>  "5")
    Configuration.create(:config_key => "nodes_file_comp", :config_value => "www.planet-lab.eu")
  end

  def self.down
    remove_index :configurations, :config_key
    drop_table :configurations
  end
end
