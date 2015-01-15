require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end
