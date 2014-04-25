class PModulesController < ApplicationController

  def index
    @catalog = Catalog.find(params[:catalog_id])
  	@p_modules = @catalog.p_modules.where(parent_id: nil)
	end

  def show
  	@p_module = PModule.find(params[:id])
    @catalog = @p_module.catalog
  end

  def destroy
    @p_module = PModule.find(params[:id])
    @catalog = @p_module.catalog
    @p_module.destroy
  	redirect_to catalog_p_modules_path(@catalog)
  end
end
