class LowercaseSlices < ActiveRecord::Migration
  def self.up
 sql = <<-SQL
	update slices set name=lower(name)
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
  end
end
