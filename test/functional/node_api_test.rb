require File.dirname(__FILE__) + '/../test_helper'
require 'node_controller'

class NodeController; def rescue_action(e) raise e end; end

class NodeControllerApiTest < ActionController::TestCase
  def setup
    @controller = NodeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
end
