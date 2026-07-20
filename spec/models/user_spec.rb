require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it "is invalid without a password" do
      user.password = nil
      user.password_confirmation = nil
      expect(user).not_to be_valid
    end

    it "is invalid when password and confirmation do not match" do
      user.password_confirmation = "different"
      expect(user).not_to be_valid
    end
  end

  describe "Associations" do
    it { is_expected.to have_many(:students).dependent(:destroy) }
  end

  describe "Enums" do
    it { is_expected.to define_enum_for(:role).with_values(admin: 0, teacher: 1) }
  end

  describe "role predicate methods" do
    let(:admin_user)   { build(:user, :admin) }
    let(:teacher_user) { build(:user, :teacher) }

    it "recognises an admin user" do
      expect(admin_user).to be_admin
      expect(admin_user).not_to be_teacher
    end

    it "recognises a teacher user" do
      expect(teacher_user).to be_teacher
      expect(teacher_user).not_to be_admin
    end
  end

  describe "Scopes" do
    describe ".by_role" do
      let!(:admin_user)   { create(:user, :admin) }
      let!(:teacher_user) { create(:user, :teacher) }

      it "returns only admin users" do
        expect(User.by_role("admin")).to contain_exactly(admin_user)
      end

      it "returns only teacher users" do
        expect(User.by_role("teacher")).to contain_exactly(teacher_user)
      end

      it "returns all users when role is nil" do
        expect(User.by_role(nil)).to match_array([ admin_user, teacher_user ])
      end

      it "returns all users when role is blank string" do
        expect(User.by_role("")).to match_array([ admin_user, teacher_user ])
      end
    end
  end

  describe "default role" do
    it "assigns teacher role by default" do
      new_user = create(:user)
      expect(new_user.role).to eq("teacher")
    end
  end

  describe "dependent destroy" do
    it "destroys associated students when the user is deleted" do
      teacher = create(:user, :teacher)
      create_list(:student, 2, user: teacher)

      expect { teacher.destroy }.to change(Student, :count).by(-2)
    end
  end
end
