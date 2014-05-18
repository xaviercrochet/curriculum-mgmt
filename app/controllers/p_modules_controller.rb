class PModulesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
  def index
    @parent = context
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
      @parent = Catalog.find(params[:catalog_id])
      @p_modules = @parent.p_modules.without_parent
      @parent
    elsif params[:program_id]
      @parent = Program.find(params[:program_id])
      @p_modules = @parent.p_modules
      @parent
    elsif params[:p_module_id]
      @parent = PModule.find(params[:p_module_id])
      @p_modules = @parent.sub_modules
      @parent
    end
  end
end
