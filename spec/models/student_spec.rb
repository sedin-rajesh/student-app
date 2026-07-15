require "rails_helper"

RSpec.describe Student, type: :model do
  subject { create(:student) }

  describe "Associations" do
    it { should belong_to(:user).counter_cache(true) }
  end

  describe "Attachments" do
    it { should have_one_attached(:profile_photo) }
    it { should have_many_attached(:documents) }
    it { should have_one_attached(:report_card) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:age) }
    it { should validate_numericality_of(:age).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:course) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:marks) }
    it { should validate_numericality_of(:marks).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe ".search" do
    let!(:student1) { create(:student, name: "John Doe", email: "john.doe@example.com") }
    let!(:student2) { create(:student, name: "Jane Smith", email: "jane.smith@example.com") }
    it "returns matching name" do
      expect(Student.search("John")).to contain_exactly(student1)
    end
    it "returns matching email" do
      expect(Student.search("jane.smith@example.com")).to contain_exactly(student2)
    end
    it "return all students when search is blank" do
      expect(Student.search(nil)).to match_array([ student1, student2 ])
    end
  end

  describe ".by_course" do
    let!(:ruby_student) { create(:student, course: "Ruby") }
    let!(:rails_student) { create(:student, course: "Rails") }
    it "filters by course" do
      expect(Student.by_course("Ruby")).to contain_exactly(ruby_student)
    end
    it "returns all students when course is blank" do
      expect(Student.by_course(nil)).to match_array([ ruby_student, rails_student ])
    end
  end

  describe ".search_by_name" do
    let!(:student) { create(:student, name: "Rajesh") }
    it "finds matching student" do
      expect(Student.search_by_name("Raj")).to contain_exactly(student)
    end
  end

  describe ".filter_by_grade" do
    let!(:grade_a) { create(:student, grade: "A") }
    let!(:grade_b) { create(:student, grade: "B") }
    it "filters by grade" do
      expect(Student.filter_by_grade("A")).to contain_exactly(grade_a)
    end
  end

  describe ".apply_filter" do
    let!(:student) do
      create(
        :student,
        name: "Rajesh",
        course: "Ruby",
        grade: "A"
      )
    end

    it "applies all filters" do
      params = {
        search: "Raj",
        course: "Ruby",
        grade: "A"
      }

      expect(Student.apply_filter(params)).to contain_exactly(student)
    end
  end

  describe "#result" do
    let(:student) { Student.build(marks: 20) }
    it "returns 'Fail' for marks less than 40" do
      expect(student.result).to eq("Fail")
    end
  end
end
