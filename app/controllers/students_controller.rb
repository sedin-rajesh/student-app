class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]
  def index
    if current_user.admin?
      @students = Student.all
    else
      @students=current_user.students
    end
    @students = @students.search(params[:search])

    if params[:course].present?
      @students = @students.where(course: params[:course])
    end
  end

  def new
    @student=Student.new
  end

  def show
  end

  def create
    @student=Student.new(student_params)
    if current_user.teacher?
      @student.user=current_user
    end
    if @student.save
      redirect_to students_path, notice: "Student created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Student updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student deleted successfully"
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

  private
    def student_params
      permitted = [ :name, :email, :age, :course, :city, :marks ]
      permitted << :user_id if current_user.admin?
      params.expect(student: permitted)
    end
end
