require 'xmlrpc/client'

class AddLocationToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :site_id, :integer, :default => 0
    add_column :nodes, :longitude, :float, :default => 0.0
    add_column :nodes, :latitude, :float, :default => 0.0
    Node.reset_column_information
    self.updateTables()
  end

  def self.down
    remove_column :nodes, :site_id
    remove_column :nodes, :longitude
    remove_column :nodes, :latitude
  end

  def self.updateTables
    XMLRPC::Config.const_set(:ENABLE_NIL_PARSER, true)
    auth = {}
    auth['AuthMethod'] = 'anonymous'
    site = Configuration.find_by_config_key("nodes_file_comp").config_value
    server = XMLRPC::Client.new3({:host=>site,:path=>'/PLCAPI/', :proxy_host=>'wwwproxy.cs.huji.ac.il', :proxy_port=>8080, :use_ssl=>true })

    server = XMLRPC::Client.new2('https://www.planet-lab.eu/PLCAPI/')
    nodes = server.call("GetNodes", auth, {}, ['hostname','site_id'])
    sites = server.call("GetSites", auth, {}, ['site_id', 'latitude', 'longitude'])
    siteHash = {}
    sites.each do |s| 
      siteHash[s['site_id']] = [s['latitude'], s['longitude']]
    end
    nodes.each do |n| 
      site = n['site_id']
      (latitude, longitude) = siteHash[site]
      if !latitude.nil? && !longitude.nil?
        node = Node.find_by_hostname(n['hostname'])
        unless node.nil?
          node.site_id = site
          node.latitude = latitude
          node.longitude = longitude
          node.save
        end
      end
    end
    
  end
end
