class ChangeSamplesIdToBigint < ActiveRecord::Migration
  def self.up
	change_column(:samples, :id, :integer, :limit => 8)
  end

  def self.down
	change_column(:samples, :id, :integer)
  end
end
