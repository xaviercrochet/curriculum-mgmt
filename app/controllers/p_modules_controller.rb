class PModulesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @parent = context
  	@p_modules = @parent.p_modules.where(parent_id: nil)
    record_history
	end

  def show
  	@p_module = PModule.find(params[:id])
    @catalog = @p_module.catalog
    @back = back
    record_history
  end

  def destroy
    @p_module = PModule.find(params[:id])
    @catalog = @p_module.catalog
    @p_module.destroy
  	redirect_to catalog_p_modules_path(@catalog)
  end

private

  def record_history
    session[:history] ||= []
    session[:history].push request.url
    session[:history] = session[:history].last(10)
  end

  def context
    if params[:catalog_id]
      Catalog.find(params[:catalog_id])
    elsif params[:program_id]
      Program.find(params[:program_id])
    elsif params[:p_module_id]
      PModule.find(params[:p_module_id])
    end
  end

  def back
    session[:history].pop unless session.nil?
    root_path if session.nil?
  end
end
