class ReportCardGenerator
  def initialize(student)
    @student=student
  end

  def call
    pdf = ReportCardPdf.new(@student).render
    @student.report_card.attach(io: StringIO.new(pdf), filename: "report_card_#{@student.id}.pdf", content_type: "application/pdf")
    NotificationMailer.report_card(@student).deliver_later
  end
end
