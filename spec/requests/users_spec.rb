require "rails_helper"

RSpec.describe "Users (HTML)", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }

  describe "GET /users" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "returns 200 OK and lists users" do
        get users_path
        expect(response).to have_http_status(:ok)
      end

      it "filters users by role" do
        get users_path, params: { role: "teacher" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as teacher" do
      before { sign_in teacher }

      it "denies access and redirects to dashboard" do
        get users_path
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:notice]).to eq("Access Denied")
      end
    end

    context "when unauthenticated" do
      it "redirects to the login page" do
        get users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
