class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]
  def index
    if current_user.admin?
      @students = Student.all
    else
      @students=current_user.students
    end
    if params[:search].present?
      search = "%#{params[:search]}%"
      @students = @students.where(
        "name LIKE ? OR email LIKE ?",
         search: search
      )
    end

    if params[:course].present?
      @students = @students.where(course: params[:course])
    end
  end

  def new
    @student=Student.new
  end

  def show
    @student=Student.find(params[:id])
  end

  def dashboard
    if current_user.admin?
      @total_students = Student.count
      @total_teachers = User.teacher.count

      @students_per_teacher =
        User.teacher
            .left_joins(:students)
            .group(:email)
            .count
    else
      students = current_user.students

      @total_students = students.count
      @ruby_students = students.where(course: "Ruby").count
      @rails_students = students.where(course: "Rails").count
      @react_students = students.where(course: "React").count
      @java_students = students.where(course: "Java").count
    end
  end

  def create
    @student=Student.build(student_params)
    if current_user.teacher?
      @student.user=current_user
    end
    if @student.save
      redirect_to students_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @student=Student.find(params[:id])
  end

  def update
    @student=Student.find(params[:id])
    if @student.update(student_params)
      redirect_to students_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student=Student.find(params[:id])
    @student.destroy
    redirect_to students_path
  end

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
      params.expect(student: [ :name, :email, :age, :course, :city, :marks, :user_id ])
    end
end
