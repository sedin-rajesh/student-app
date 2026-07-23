module DeviseHelpers
  def auth_headers_for(user)
    post api_v1_login_path,
         params: { user: { email: user.email, password: user.password } },
         as: :json
    token = response.parsed_body["token"]
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include DeviseHelpers, type: :request
end
