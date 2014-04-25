class PModulesController < ApplicationController

  def index
    @catalog = Catalog.find(params[:catalog_id])
  	@p_modules = @catalog.p_modules
	end

  def show
  	@p_module = PModule.find(params[:id])
    @catalog = @p_module.catalog
  end

  def destroy
    @catalog = Catalog.find(params[:id])
  	@p_module = @catalog.p_modules.find(params[:format])
  	@p_module.destroy
  	redirect_to catalog_p_modules_path(@program)
  end
end
