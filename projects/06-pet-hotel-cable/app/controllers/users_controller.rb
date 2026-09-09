class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    return redirect_to(root_path) if logged_in?

    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Cadastro feito. Bem-vindo à Pousada do Thor."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
