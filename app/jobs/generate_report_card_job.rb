class GenerateReportCardJob < ApplicationJob
  queue_as :default

  def perform(id)
    student = Student.find(id)
    pdf = ReportCardPdf.new(student).render
    student.report_card.attach(io: StringIO.new(pdf), filename: "report_card.pdf",content_type: "application/pdf")
  end
end
