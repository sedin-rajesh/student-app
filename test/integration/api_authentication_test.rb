require "test_helper"

class ApiAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should deny access to api/v1/students without token" do
    get api_v1_students_url, as: :json
    assert_response :unauthorized
    assert_equal "You need to sign in or sign up before continuing.", JSON.parse(response.body)["error"]
  end

  test "should login successfully and access api/v1/students with token" do
    post api_v1_login_url, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?("token")
    token = json_response["token"]

    get api_v1_students_url, headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :success
  end
end
