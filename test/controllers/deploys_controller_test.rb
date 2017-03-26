require 'test_helper'

class DeploysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get deploys_index_url
    assert_response :success
  end

  test "should get new" do
    get deploys_new_url
    assert_response :success
  end

  test "should get create" do
    get deploys_create_url
    assert_response :success
  end

  test "should get detail" do
    get deploys_detail_url
    assert_response :success
  end

end
