class SubModulesController < ApplicationController
	before_filter :p_module
	
	def index
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
		@sub_module = @p_module.sub_modules.find(params[:id])
	end

	def edit
		@sub_module = @p_module.sub_modules.find(params[:id])
	end

	def update
		@sub_module = @p_module.sub_modules.find(params[:id])

		if @sub_module.update(params[:sub_module].permit(:name))
			redirect_to catalog_program_p_module_sub_module_path(@catalog, @program, @p_module, @sub_module)
		else
			render 'edit'
		end
	end

	def destroy
		@sub_module = @p_module.sub_modules.find(params[:id])
		@sub_module.destroy
		redirect_to catalog_program_p_module_sub_modules_path
	end

	private
		
		def sub_module_params
			params.require(:sub_module).permit(:name)
		end

		def p_module
			@p_module = PModule.find(params[:p_module_id])
		end

		def catalog
			@catalog = Catalog.find(params[:catalog_id])
		end

		def program
			@program = Program.find(params[:program_id])
		end
end
