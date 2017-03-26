require 'test_helper'

class ContainersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get containers_index_url
    assert_response :success
  end

end
