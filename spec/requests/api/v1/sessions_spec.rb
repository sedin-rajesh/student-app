require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { create(:user, :teacher) }

  describe "POST /api/v1/login" do
    context "with valid credentials" do
      it "returns status 200 with a JWT token" do
        post api_v1_login_path,
             params: { user: { email: user.email, password: "Password123!" } },
             as: :json

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body).to have_key("token")
        expect(body["token"]).not_to be_blank
      end

      it "returns user attributes in the response body" do
        post api_v1_login_path,
             params: { user: { email: user.email, password: "Password123!" } },
             as: :json

        body = response.parsed_body
        expect(body["user"]["email"]).to eq(user.email)
        expect(body["user"]["role"]).to eq("teacher")
        expect(body["user"]).to have_key("id")
      end
    end

    context "with invalid password" do
      it "returns 401 Unauthorized" do
        post api_v1_login_path,
             params: { user: { email: user.email, password: "wrong_password" } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with non-existent email" do
      it "returns 401 Unauthorized" do
        post api_v1_login_path,
             params: { user: { email: "nobody@example.com", password: "Password123!" } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/logout" do
    context "when authenticated" do
      it "returns 204 No Content" do
        headers = auth_headers_for(user)
        delete api_v1_logout_path, headers: headers, as: :json

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
