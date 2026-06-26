class Api::V1::StudentsController < Api::V1::BaseController
  before_action :set_student, only: [ :show, :update, :destroy ]

  def teacher_students
    teacher=User.teacher.find(params[:teacher_id])
    render json: teacher.students
  end

  def index
    if current_user.admin?
      students = Student.all
    else
      students=current_user.students
    end
    students = students.search(params[:search])

    if params[:name].present?
      students = students.where(
        "LOWER(name) LIKE ?", "%#{params[:name].downcase}%"
      )
    end

    if params[:grade].present?
      students = students.where(grade: params[:grade])
    end

    if params[:course].present?
      students = students.where(course: params[:course])
    end

    render json: students
  end

  def create_for_teacher
    teacher=User.teacher.find(params[:teacher_id])
    student=teacher.students.build(student_params)
    if student.save
      render json: student, status: :created
    else
      render json: {
        errors: student.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def show
    render json: @student
  end

  def create
    student=Student.new(student_params)
    if current_user.teacher?
      student.user=current_user
    end
    if student.save
      render json: student, status: :created
    else
      render json: {
        errors: student.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      render json: @student
    else
      render json: {
        errors: @student.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    render json: {
      message: "Student deleted successfully"
    }, status: :ok
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
      params.require(:student).permit(*permitted)
    end
end
