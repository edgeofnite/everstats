class NodeApi < ActionWebService::API::Base
  api_method :status, :expects => [{:array=>[:string]}], :returns => [{:array=>[NodeStatus]}]
end
