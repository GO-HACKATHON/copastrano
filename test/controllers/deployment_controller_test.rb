require 'test_helper'

class DeploymentControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get deployment_index_url
    assert_response :success
  end

  test "should get new" do
    get deployment_new_url
    assert_response :success
  end

end
