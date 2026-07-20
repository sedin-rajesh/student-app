require "rails_helper"

RSpec.describe GenerateReportCardJob, type: :job do
  include ActiveJob::TestHelper

  let(:teacher) { create(:user, :teacher) }
  let(:student) { create(:student, user: teacher) }

  describe "enqueuing" do
    it "enqueues the job on the default queue" do
      expect do
        GenerateReportCardJob.perform_later(student.id)
      end.to have_enqueued_job(GenerateReportCardJob)
        .with(student.id)
        .on_queue("default")
    end
  end

  describe "#perform" do
    it "attaches a report_card PDF to the student" do
      described_class.new.perform(student.id)
      expect(student.reload.report_card).to be_attached
    end

    it "attaches a file named report_card.pdf" do
      described_class.new.perform(student.id)
      expect(student.reload.report_card.filename.to_s).to eq("report_card.pdf")
    end

    it "attaches a PDF content type" do
      described_class.new.perform(student.id)
      expect(student.reload.report_card.content_type).to eq("application/pdf")
    end
  end

  describe "failure scenario" do
    it "raises ActiveRecord::RecordNotFound for a non-existent student id" do
      expect do
        described_class.new.perform(999_999)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
