class Api::V1::StudentsController < Api::V1::BaseController
  before_action :set_student, only: [ :show, :update, :destroy ]

  def index
    students = students_scope.apply_filter(params)
    render json: students
  end

  def show
    render json: @student
  end

  def create
    student =
      if current_user.admin?
        if params[:teacher_id].present?
          User.teacher.find(params[:teacher_id]).students.build(student_params)
        else
          Student.new(student_params)
        end
      else
        current_user.students.build(student_params)
      end
    if student.save
      render json: student, status: :created
    else
      render_validation_error(student)
    end
  end

  def update
    if @student.update(student_params)
      render json: @student
    else
      render_validation_error(@student)
    end
  end

  def destroy
    @student.destroy
    head :no_content
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
      permitted = [ :name, :email, :age, :course, :city, :marks ]
      permitted << :user_id if current_user.admin?
      params.require(:student).permit(*permitted)
    end

    def students_scope
      if current_user.admin?
        return User.teacher.find(params[:teacher_id]).students if params[:teacher_id].present?
        Student.all
      else
        current_user.students
      end
    end
end
