class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy, :generate_report_card, :remove_profile_photo, :remove_document, :cancel ]
  def index
    if current_user.admin?
      @students = Student.all
    else
      @students = current_user.students
    end
    @students = @students.search(params[:search])

    if params[:course].present?
      @students = @students.where(course: params[:course])
    end
  end

  def new
    @student = Student.new
  end

  def show
    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "student", locals: { student: @student }
        else
          render :show
        end
      end
    end
  end

  def create
    @student = Student.new(student_params)
    if current_user.teacher?
      @student.user = current_user
    end
    if @student.save
      NotificationMailer.student_created(@student).deliver_later
      flash.now[:notice] = "Student created successfully."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to students_path, notice: "Student created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("student_form", template: "students/new"), status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    documents_uploaded = Array(params.dig(:student, :documents)).reject(&:blank?).any?
    if @student.update(student_params)
      flash.now[:notice] = "Student updated successfully"
      if @student.saved_change_to_user_id? && @student.user.present?
        NotificationMailer.teacher_assigned(@student).deliver_later
        NotificationMailer.student_assigned(@student).deliver_later
      end
      if documents_uploaded
        NotificationMailer.documents_uploaded(@student).deliver_later
      end
      if @student.saved_change_to_marks?
        NotificationMailer.marks_posted(@student).deliver_later
      end
      respond_to do |format|
        format.html { redirect_to students_path, notice: "Student updated successfully" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(helpers.dom_id(@student), template: "students/edit"), status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @student.destroy
    flash.now[:notice] = "Student deleted successfully."
    respond_to do |format|
      format.html do
        redirect_to students_path, notice: "Student deleted successfully"
      end
      format.turbo_stream
    end
  end

  def remove_profile_photo
    if @student.profile_photo.attached?
      @student.profile_photo.purge
      redirect_to @student, notice: "Profile photo removed successfully"
    else
      redirect_to @student, alert: "No profile photo to remove"
    end
  end

  def remove_document
    document = @student.documents.find(params[:attachment_id])
    document.purge
    redirect_to @student, notice: "Document removed successfully"
  end

  def cancel
    @student = Student.find(params[:id])
    render partial: "student", locals: { student: @student }
  end

  def cancel
    @student = Student.find(params[:id])
    render partial: "student", locals: { student: @student }
  end

  def generate_report_card
    @student = Student.find(params[:id])
    GenerateReportCardJob.perform_later(@student.id)
    redirect_to @student, notice: "Report card generation has been queued. You will receive an email once it's ready."
    NotificationMailer.report_card(@student).deliver_later
  end
  private
    def set_student
    @student =
      if current_user.admin?
        Student.find(params[:id])
      else
        current_user.students.find(params[:id])
      end
    end

    def student_params
      permitted = [ :name, :email, :age, :course, :city, :marks, :profile_photo, documents: [] ]
      permitted << :user_id if current_user.admin?
      params.expect(student: permitted)
    end
end
