class UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [ :show, :update, :destroy ]
  def index
    users = User.all
    users = users.by_role(params[:role])
    render json: users
  end

  def show
    render json: @user
  end

  def create
    user=User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: {
        message: "User updated successfully",
        user: @user
      }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy

    render json: {
      message: "User deleted successfully"
    }, status: :ok
  end

  def teachers_by_subject
    teachers = User.teacher
    teachers = teachers.where(subject: params[:subject]) if params[:subject].present?
    render json: teachers
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :role
    )
  end

  def require_admin
    # redirect_to dashboard_path, notice: "Access Denied" unless current_user.admin?
    render json: { error: "Access denied" }, status: :forbidden unless current_user&.admin?
  end
end
