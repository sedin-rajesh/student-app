require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:other_teacher) { create(:user, :teacher) }
  let(:admin_headers) { auth_headers_for(admin) }

  describe "GET /api/v1/users" do
    context "when authenticated as admin" do
      let!(:teacher1) { create(:user, :teacher) }
      let!(:teacher2) { create(:user, :teacher) }

      it "returns all users with status 200" do
        get api_v1_users_path, headers: admin_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.length).to eq(3)
      end

      it "filters users by role" do
        get api_v1_users_path, headers: admin_headers,
            params: { role: "teacher" }, as: :json

        expect(response).to have_http_status(:ok)
        roles = response.parsed_body.map { |u| u["role"] }
        expect(roles).to all(eq("teacher"))
      end
    end

    context "when authenticated as teacher" do
      it "returns 403 Forbidden" do
        get api_v1_users_path, headers: auth_headers_for(other_teacher), as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get api_v1_users_path, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/users/:id" do
    context "when user exists" do
      it "returns the user with status 200" do
        get api_v1_user_path(other_teacher), headers: admin_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["id"]).to eq(other_teacher.id)
      end
    end

    context "when user does not exist" do
      it "returns 404 Not Found" do
        get api_v1_user_path(id: 999_999), headers: admin_headers, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/users" do
    let(:valid_attributes) do
      {
        user: {
          email:                 "newteacher@example.com",
          password:              "Password123!",
          password_confirmation: "Password123!",
          role:                  "teacher"
        }
      }
    end

    context "when admin creates a user" do
      it "creates a user and returns 201" do
        admin_headers
        expect do
          post api_v1_users_path,
               headers: admin_headers,
               params:  valid_attributes,
               as: :json
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["email"]).to eq("newteacher@example.com")
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) do
        { user: { email: "bad", password: "short", password_confirmation: "mismatch" } }
      end

      it "returns 422 Unprocessable Entity" do
        post api_v1_users_path,
             headers: admin_headers,
             params:  invalid_attributes,
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to have_key("errors")
      end
    end
  end

  describe "PATCH /api/v1/users/:id" do
    context "when admin updates a user" do
      it "updates the user and returns 200" do
        patch api_v1_user_path(other_teacher),
              headers: admin_headers,
              params:  { user: { email: "updated@example.com",
                                 password: "Password123!",
                                 password_confirmation: "Password123!" } },
              as: :json

        expect(response).to have_http_status(:ok)
        expect(other_teacher.reload.email).to eq("updated@example.com")
      end
    end

    context "with invalid attributes" do
      it "returns 422 with errors" do
        patch api_v1_user_path(other_teacher),
              headers: admin_headers,
              params:  { user: { email: "" } },
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /api/v1/users/:id" do
    context "when admin deletes a user" do
      let!(:target_user) { create(:user, :teacher) }

      it "deletes the user and returns 204" do
        admin_headers
        expect do
          delete api_v1_user_path(target_user), headers: admin_headers, as: :json
        end.to change(User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when teacher tries to delete a user" do
      let!(:target_user) { create(:user, :teacher) }

      it "returns 403 Forbidden and does not delete" do
        teacher_headers = auth_headers_for(other_teacher)
        expect do
          delete api_v1_user_path(target_user), headers: teacher_headers, as: :json
        end.not_to change(User, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/teachers_by_subject" do
    let!(:math_teacher) { create(:user, :teacher, :with_subject, subject: "Mathematics") }
    let!(:sci_teacher)  { create(:user, :teacher, :with_subject, subject: "Science") }

    it "returns teachers filtered by subject" do
      get teachers_by_subject_api_v1_users_path,
          headers: admin_headers,
          params: { subject: "Mathematics" },
          as: :json

      expect(response).to have_http_status(:ok)
      emails = response.parsed_body.map { |u| u["email"] }
      expect(emails).to contain_exactly(math_teacher.email)
    end

    it "returns all teachers when no subject is specified" do
      get teachers_by_subject_api_v1_users_path,
          headers: admin_headers,
          as: :json

      expect(response).to have_http_status(:ok)
      emails = response.parsed_body.map { |u| u["email"] }
      expect(emails).to include(math_teacher.email, sci_teacher.email)
    end
  end
end
