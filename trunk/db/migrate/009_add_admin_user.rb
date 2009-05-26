class AddAdminUser < ActiveRecord::Migration
  def self.up
     a = User.new(:login => "admin", :password => "admin", :password_confirmation => "admin")
     a.save
  end

  def self.down
    User.delete(1)
  end
end
