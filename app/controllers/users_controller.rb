class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:succes] = "Welcome !"
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
  	@user =  User.find(params[:id])

    if @user.update(params[:user]).permit(:name, :email, :user_type, :password, :password_confirmation)
      redirect_to @user
    else
      render 'update'
    end
  end

  def index
    @users = User.all
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :user_type, :password, :password_confirmation)
    end
end
