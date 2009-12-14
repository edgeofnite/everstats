class NodeStatus < ActionWebService::Struct
  member :name, String
  member :numslices, Integer
end

class NodeController < ApplicationController
  wsdl_service_name 'Node'
  web_service_api NodeApi
  web_service_scaffold :invocation if Rails.env == 'development'

  def upper_case(s)
    s.upcase
  end

  def test_list(array)
    result = ""
    array.each do |i|
      result += "%d - " % i
    end
    result
  end

  def status(nodelist)
    result = []
    #debugger
    nodelist.each do |n|
      node = Node.find_by_hostname(n)
      numslices = Dayusagesummary.calculate(:count, :slice_id, :conditions => "slice_id = -1 and node_id = #{node.id}", :having => "day = now()'")
      item = NodeStatus.new
      item.name = n
      item.numslices = numslices
      result.push(item)
    end
    result
  end
end