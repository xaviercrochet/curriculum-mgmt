class UsersController < ApplicationController

  def choose_catalog
    @current_catalog = current_user.catalog
  end

  def update_catalog
    @catalog = Catalog.find(params[:user][:catalog_id])
    current_user.catalog = @catalog
    current_user.save
    redirect_to user_choose_catalog_path
  end
  # def new
  # 	@user = User.new
  # end

  # def show
  #   @user = User.find(params[:id])
  # end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     p @user
  #     sign_in(@user)
  #     flash[:succes] = "Welcome !"
  #     redirect_to @user
  #   else
  #     render 'new'
  #   end
  # end


  # def update
  # 	@user =  User.find(params[:id])

  #   if @user.update(params[:user]).permit(:name, :email, :user_type, :password, :password_confirmation)
  #     redirect_to @user
  #   else
  #     render 'update'
  #   end
  # end

  # def index
  #   @users = User.all
  # end

  # private
  #   def user_params
  #     params.require(:user).permit(:name, :email, :user_type, :password, :password_confirmation)
  #   end
end
