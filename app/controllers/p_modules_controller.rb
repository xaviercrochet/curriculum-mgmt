class PModulesController < ApplicationController
  after_action :record_history

  def index
    @parent = context
  	@p_modules = @parent.p_modules.where(parent_id: nil)
	end

  def show
  	@p_module = PModule.find(params[:id])
    @catalog = @p_module.catalog
    @back = back
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
