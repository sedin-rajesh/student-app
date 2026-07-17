require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:teacher) { create(:user, :teacher) }
  let(:student) { create(:student, user: teacher) }

  describe "#student_created" do
    subject(:mail) { described_class.student_created(student) }

    it "delivers to the student's email" do
      expect(mail.to).to contain_exactly(student.email)
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your student profile has been created")
    end

    it "renders the student name in the body" do
      expect(mail.body.encoded).to include(student.name)
    end
  end

  describe "#teacher_assigned" do
    subject(:mail) { described_class.teacher_assigned(student) }

    it "delivers to the student's email" do
      expect(mail.to).to contain_exactly(student.email)
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("A teacher has been assigned to you!")
    end

    it "renders the teacher information in the body" do
      expect(mail.body.encoded).to include(teacher.email)
    end
  end

  describe "#student_assigned" do
    subject(:mail) { described_class.student_assigned(student) }

    it "delivers to the teacher's email" do
      expect(mail.to).to contain_exactly(teacher.email)
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("A new student has been added to your class")
    end

    it "renders the student name in the body" do
      expect(mail.body.encoded).to include(student.name)
    end
  end

  describe "#documents_uploaded" do
    subject(:mail) { described_class.documents_uploaded(student) }

    it "delivers to the teacher's email" do
      expect(mail.to).to contain_exactly(teacher.email)
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Student has uploaded new documents")
    end

    it "renders the student name in the body" do
      expect(mail.body.encoded).to include(student.name)
    end
  end

  describe "#marks_posted" do
    subject(:mail) { described_class.marks_posted(student) }

    it "delivers to the student's email" do
      expect(mail.to).to contain_exactly(student.email)
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your marks have been posted")
    end

    it "renders the course name in the body" do
      expect(mail.body.encoded).to include(student.course)
    end

    it "renders 'Marks Updated' heading in the body" do
      expect(mail.body.encoded).to include("Marks Updated")
    end
  end

  describe "#report_card" do
    subject(:mail) { described_class.report_card(student) }

    it "delivers to the student's email" do
      expect(mail.to).to contain_exactly(student.email)
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your report card")
    end

    it "attaches a PDF file named report_card.pdf" do
      attachment = mail.attachments.find { |a| a.filename == "report_card.pdf" }
      expect(attachment).not_to be_nil
      expect(attachment.content_type).to start_with("application/pdf")
    end
  end
end
