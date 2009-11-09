require 'xmlrpc/client'

class AddLocationToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :site_id, :integer, :default => 0
    add_column :nodes, :longitude, :float, :default => 0.0
    add_column :nodes, :latitude, :float, :default => 0.0
  end

  def self.down
    remove_column :nodes, :siteid
    remove_column :nodes, :longitude
    remove_column :nodes, :latitude
  end

  def updateTables
    XMLRPC::Config::ENABLE_NIL_PARSER = true
    auth = {}
    auth['AuthMethod'] = 'anonymous'
    server = XMLRPC::Client.new3({:host=>'www.everlab.org',:path=>'/PLCAPI/', :proxy_host=>'wwwproxy.cs.huji.ac.il', :proxy_port=>8080, :use_ssl=>true })

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
        Node.find_by_hostname(n['hostname'])
        Node.site_id = site
        Node.latitude = latitude
        Node.longitude = longitude
        Node.save
      end
    end
    
  end
end
