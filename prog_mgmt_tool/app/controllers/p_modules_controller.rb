class PModulesController < ApplicationController

  def index
    @parent = context
  	@p_modules = @parent.p_modules.where(parent_id: nil)
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

private

  def context
    if params[:catalog_id]
      Catalog.find(params[:catalog_id])
    elsif params[:program_id]
      Program.find(params[:program_id])
    end
  end
end
