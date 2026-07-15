require "rails_helper"

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:students).dependent(:destroy) }
  end
  describe "Enums" do
    it do
      should define_enum_for(:role).with_values(admin: 0, teacher: 1)
    end
  end
  describe "Scopes" do
    let!(:admin_user) { create(:user, role: :admin) }
    let!(:teacher_user) { create(:user, role: :teacher) }

    describe ".by_role" do
      it "returns only admin users" do
        expect(User.by_role("admin")).to contain_exactly(admin)
      end
      it "returns only teacher users" do
        expect(User.by_role("teacher")).to contain_exactly(teacher_user)
      end
      it "returns all users when role is nil" do
        expect(User.by_role(nil)).to contain_exactly(admin_user, teacher_user)
      end
      it "returns all users when role is empty string" do
        expect(User.by_role("")).to contain_exactly(admin_user, teacher_user)
      end
    end
  end
end
