class StudentsController < ApplicationController
  def index
    @students = Student.all

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
    @total_students=Student.count
    @ruby_students=Student.where(course: "Ruby").count
    @rails_students=Student.where(course: "Rails").count
    @react_students=Student.where(course: "React").count
    @java_students=Student.where(course: "Java").count
  end

  def create
    @student=Student.new(student_params)
    if @student.save
      redirect_to @student
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

  private
    def student_params
      params.expect(student: [ :name, :email, :age, :course, :city, :marks ])
    end
end
