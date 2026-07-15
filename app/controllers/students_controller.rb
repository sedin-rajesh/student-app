class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy, :remove_profile_photo, :remove_document ]
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
  end

  def create
    @student = Student.new(student_params)
    if current_user.teacher?
      @student.user = current_user
    end
    if @student.save
      NotificationMailer.student_created(@student).deliver_now
      redirect_to students_path, notice: "Student created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    documents_uploaded = params.dig(:student, :documents).present?
    if @student.update(student_params)
      redirect_to @student, notice: "Student updated successfully"
      if @student.saved_change_to_user_id? && @student.user.present?
        NotificationMailer.teacher_assigned(@student).deliver_now
        NotificationMailer.student_assigned(@student).deliver_now
      end
      if documents_uploaded
        NotificationMailer.documents_uploaded(@student).deliver_now
      end
      if @student.saved_change_to_marks?
        NotificationMailer.marks_posted(@student).deliver_now
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student deleted successfully"
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
