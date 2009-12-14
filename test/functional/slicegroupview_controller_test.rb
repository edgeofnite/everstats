require File.dirname(__FILE__) + '/../test_helper'
require 'slicegroupview_controller'

# Re-raise errors caught by the controller.
class SlicegroupviewController; def rescue_action(e) raise e end; end

class SlicegroupviewControllerTest < ActionController::TestCase
  def setup
    @controller = SlicegroupviewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
