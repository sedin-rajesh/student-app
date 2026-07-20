require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }

  describe "GET /dashboard" do
    context "when authenticated as admin" do
      before do
        sign_in admin
      end

      it "returns 200 OK and assigns variables" do
        get dashboard_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Dashboard")
      end
    end

    context "when authenticated as teacher" do
      before do
        sign_in teacher
      end

      it "returns 200 OK and lists teacher's student metrics" do
        create_list(:student, 2, user: teacher, course: "Ruby")
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when unauthenticated" do
      it "redirects to the login page" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
