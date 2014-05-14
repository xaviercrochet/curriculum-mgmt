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
end
