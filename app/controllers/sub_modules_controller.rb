class SubModulesController < ApplicationController
	before_action :authenticate_user!
	load_and_authorize_resource
	
	def index
		@p_module = PModule.find(params[:p_module_id])
		@sub_modules = @p_module.sub_modules
	end

	def show
		@sub_module = SubModule.find(params[:id])
		@p_module = @sub_module.p_module
	end


	def destroy
		@p_module = PModule.find(params[:id])
		@sub_module = @p_module.sub_modules.find(params[:format])
		@sub_module.destroy
		redirect_to p_module_sub_modules_path(@p_module)
	end
end
