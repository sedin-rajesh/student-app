class NotificationMailer < ApplicationMailer
  def student_created(student)
    @student = student
    mail(
      to: @student.email,
      subject: "Your student profile has been created"
    )
  end

  def teacher_assigned(student)
    @student = student
    @teacher = @student.user
    mail(
      to: @student.email,
      subject: "A teacher has been assigned to you!"
    )
  end

  def student_assigned(student)
    @student = student
    @teacher = @student.user
    mail(
      to: @teacher.email,
      subject: "A new student has been added to your class"
    )
  end

  def documents_uploaded(student)
    @student = student
    @teacher = student.user
    @documents = @student.documents
    mail(
      to: @teacher.email,
      subject: "Student has uploaded new documents"
    )
  end

  def marks_posted(student)
    @student = student
    mail(
      to: @student.email,
      subject: "Your marks have been posted"
    )
  end

  def report_card(student)
    @student = student
    pdf = ReportCardPdf.new(@student).render
    attachments["report_card.pdf"] = pdf
    mail(
      to: @student.email,
      subject: "Your report card"
    )
  end
end
