class NodeStatus < ActionWebService::Struct
  member :name, String
  member :numslices, Integer
end

class NodeController < ApplicationController
  wsdl_service_name 'Node'
  web_service_api NodeApi
  web_service_scaffold :invocation if Rails.env == 'development'

  def status(nodelist)
    result = []
    nodelist.each do |n|
      node = Node.find_by_hostname(n)
      numslices = Dayusagesummary.maximum(:nitems, :conditions => "slice_id = -1 and node_id = #{node.id} and day = date(date_sub(now(), interval 1 day))")
      item = NodeStatus.new
      item.name = n
      item.numslices = numslices
      result.push(item)
    end
    result
  end
end
