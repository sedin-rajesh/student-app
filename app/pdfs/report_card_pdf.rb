class ReportCardPdf
  def initialize(student)
    @student = student
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.text "ABC Academy", size: 24, style: :bold, align: :center

      pdf.move_down 20

      pdf.text "REPORT CARD", size: 20, style: :bold, align: :center

      pdf.move_down 30

      pdf.text "Student Name: #{@student.name}"
      pdf.text "Email: #{@student.email}"
      pdf.text "Course: #{@student.course}"

      pdf.move_down 20

      pdf.text "Marks: #{@student.marks}"
      pdf.text "Result: #{@student.result}"

      pdf.move_down 30

      pdf.text "Teacher email: #{@student.user.email}"

      pdf.move_down 40

      pdf.text "ABC Academy"
    end.render
  end
end
