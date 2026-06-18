class UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.all
    @users = @users.where(role: params[:role]) if params[:role].present?
  end

  private
  def require_admin
    redirect_to dashboard_path, notice: "Access Denied" unless current_user.admin?
  end
end
