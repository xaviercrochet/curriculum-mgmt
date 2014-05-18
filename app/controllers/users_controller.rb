class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource


  def choose_catalog
    @current_catalog = current_user.catalog
  end

  def update_catalog
    @catalog = Catalog.find(params[:user][:catalog_id])
    current_user.catalog = @catalog
    current_user.save
    redirect_to user_choose_catalog_path(current_user)
  end

  def manage_years
    @years = Year.current
  end

  def edit_year
    @year = Year.find(params[:year_id])
  end
end
