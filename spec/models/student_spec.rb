require "rails_helper"

RSpec.describe Student, type: :model do
  subject(:student) { build(:student) }

  describe "Associations" do
    it { is_expected.to belong_to(:user).counter_cache(true) }
  end

  describe "Active Storage Attachments" do
    it { is_expected.to have_one_attached(:profile_photo) }
    it { is_expected.to have_many_attached(:documents) }
    it { is_expected.to have_one_attached(:report_card) }
  end

  describe "Validations" do
    subject { create(:student) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_presence_of(:age) }
    it { is_expected.to validate_numericality_of(:age).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:course) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:marks) }
    it do
      is_expected.to validate_numericality_of(:marks)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(100)
    end
  end

  describe "email format validation" do
    it "is invalid with a malformed email" do
      student.email = "not-an-email"
      expect(student).not_to be_valid
      expect(student.errors[:email]).to be_present
    end

    it "is valid with a properly formatted email" do
      student.email = "valid@example.com"
      expect(student).to be_valid
    end
  end

  describe "COURSES constant" do
    it "contains expected courses" do
      expect(Student::COURSES).to match_array(%w[Ruby Rails React Java])
    end

    it "is frozen" do
      expect(Student::COURSES).to be_frozen
    end
  end

  describe "Scopes" do
    describe ".search" do
      let!(:teacher) { create(:user, :teacher) }
      let!(:john)    { create(:student, name: "John Doe",   email: "john.doe@example.com",   user: teacher) }
      let!(:jane)    { create(:student, name: "Jane Smith", email: "jane.smith@example.com", user: teacher) }

      it "returns students matching by name" do
        expect(Student.search("John")).to contain_exactly(john)
      end

      it "returns students matching by email" do
        expect(Student.search("jane.smith@example.com")).to contain_exactly(jane)
      end

      it "returns all students when term is nil" do
        expect(Student.search(nil)).to match_array([ john, jane ])
      end

      it "returns all students when term is blank" do
        expect(Student.search("")).to match_array([ john, jane ])
      end

      it "is case-insensitive for name search" do
        expect(Student.search("john")).to contain_exactly(john)
      end
    end

    describe ".by_course" do
      let!(:teacher)       { create(:user, :teacher) }
      let!(:ruby_student)  { create(:student, course: "Ruby",  user: teacher) }
      let!(:rails_student) { create(:student, course: "Rails", user: teacher) }

      it "filters by course" do
        expect(Student.by_course("Ruby")).to contain_exactly(ruby_student)
      end

      it "returns all students when course is nil" do
        expect(Student.by_course(nil)).to match_array([ ruby_student, rails_student ])
      end

      it "returns all students when course is blank string" do
        expect(Student.by_course("")).to match_array([ ruby_student, rails_student ])
      end
    end

    describe ".search_by_name" do
      let!(:teacher) { create(:user, :teacher) }
      let!(:rajesh)  { create(:student, name: "Rajesh",       user: teacher) }
      let!(:other)   { create(:student, name: "Someone Else", user: teacher) }

      it "returns students whose name matches the term" do
        expect(Student.search_by_name("Raj")).to contain_exactly(rajesh)
      end

      it "returns all students when name is nil" do
        expect(Student.search_by_name(nil)).to match_array([ rajesh, other ])
      end

      it "returns all students when name is blank" do
        expect(Student.search_by_name("")).to match_array([ rajesh, other ])
      end
    end

    describe ".filter_by_grade" do
      let!(:teacher) { create(:user, :teacher) }
      let!(:grade_a) { create(:student, grade: "A", user: teacher) }
      let!(:grade_b) { create(:student, grade: "B", user: teacher) }

      it "filters by grade" do
        expect(Student.filter_by_grade("A")).to contain_exactly(grade_a)
      end

      it "returns all when grade is nil" do
        expect(Student.filter_by_grade(nil)).to match_array([ grade_a, grade_b ])
      end
    end

    describe ".apply_filter" do
      let!(:teacher) { create(:user, :teacher) }
      let!(:target)  { create(:student, name: "Rajesh", course: "Ruby",  grade: "A", user: teacher) }
      let!(:other)   { create(:student, name: "Alice",  course: "Rails", grade: "B", user: teacher) }

      it "applies all filters and returns matching students" do
        params = { search: "Raj", course: "Ruby", grade: "A" }
        expect(Student.apply_filter(params)).to contain_exactly(target)
      end

      it "returns all students when params are empty" do
        expect(Student.apply_filter({})).to match_array([ target, other ])
      end
    end
  end

  describe "#result" do
    context "when marks are 35 or above" do
      it "returns 'Pass'" do
        student.marks = 35
        expect(student.result).to eq("Pass")
      end

      it "returns 'Pass' for exactly 100 marks" do
        student.marks = 100
        expect(student.result).to eq("Pass")
      end
    end

    context "when marks are below 35" do
      it "returns 'Fail'" do
        student.marks = 34
        expect(student.result).to eq("Fail")
      end

      it "returns 'Fail' for 0 marks" do
        student.marks = 0
        expect(student.result).to eq("Fail")
      end
    end
  end

  describe "profile_photo validation" do
    it "adds an error for non-image content type" do
      persisted = create(:student)
      persisted.profile_photo.attach(
        io: StringIO.new("fake pdf content"),
        filename: "doc.pdf",
        content_type: "application/pdf"
      )
      expect(persisted).not_to be_valid
      expect(persisted.errors[:profile_photo]).to include("must be a JPEG or PNG image")
    end
  end

  describe "documents validation" do
    it "adds an error when a document is not a PDF or image" do
      persisted = create(:student)
      persisted.documents.attach(
        io: StringIO.new("fake content"),
        filename: "text.txt",
        content_type: "text/plain"
      )
      expect(persisted).not_to be_valid
      expect(persisted.errors[:documents]).to include("must be a PDF or an image (JPEG/PNG)")
    end
  end
end
