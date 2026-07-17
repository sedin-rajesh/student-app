class GenerateReportCardJob < ApplicationJob
  queue_as :default

  def perform(id)
    student = Student.find(id)
    ReportCardGenerator.new(student).call
  end
end
