class SubModulesController < ApplicationController
	
	def index
		@p_module = PModule.find(params[:p_module_id])
		@sub_modules = @p_module.sub_modules
	end

	def new
		@sub_module = SubModule.new
	end

	def create
		@sub_module = @p_module.sub_modules.create(sub_module_params)
		redirect_to catalog_program_p_module_sub_module_path(@catalog, @program, @p_module, @sub_module)
	end

	def show
		@sub_module = SubModule.find(params[:id])
		@p_module = @sub_module.p_module
	end

	def edit
		@sub_module = @p_module.sub_modules.find(params[:format])
	end

	def update
		@sub_module = @p_module.sub_modules.find(params[:format])

		if @sub_module.update(params[:sub_module].permit(:name))
			redirect_to catalog_program_p_module_sub_module_path(@catalog, @program, @p_module, @sub_module)
		else
			render 'edit'
		end
	end

	def destroy
		@p_module = PModule.find(params[:id])
		@sub_module = @p_module.sub_modules.find(params[:format])
		@sub_module.destroy
		redirect_to p_module_sub_modules_path(@p_module)
	end

	private
		
		def sub_module_params
			params.require(:sub_module).permit(:name)
		end

		def p_module
			if params[:p_module_id]
				@p_module = PModule.find(params[:p_module_id])
			else
				@p_module = PModule.find(params[:id])
			end
		end
end
