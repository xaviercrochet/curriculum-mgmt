class PModulesController < ApplicationController
  before_filter :program, :catalog

  def index
  	@p_modules = @program.p_modules
	end

  def show
  	@p_module = @program.p_modules.find(params[:id])
  end

  def update
  	@p_module = @program.p_modules.find(params[:id])

  	if @p_module.update(params[:p_module].permit(:name, :module_type, :credits))
  		redirect_to catalog_program_p_module_path(@catalog, @program, @p_module)
  	else
  		render 'edit'
  	end
  end

  def destroy
  	@p_module = @program.p_modules.find(params[:id])
  	@p_module.destroy
  	redirect_to catalog_program_p_modules_path
  end
  
  def new
  	@p_module = PModule.new
  end

  def create
  	@p_module = @program.p_modules.create(p_module_params)
  	redirect_to catalog_program_p_module_path(@catalog, @program, @p_module)
  end

  def edit
  	@p_module = @program.p_modules.find(params[:id])
  end

  private
		def program
	  	@program = Program.find(params[:program_id])
	  end

	  def catalog
	  	@catalog = Catalog.find(params[:catalog_id])
	  end

	  def p_module_params
	  	params.require(:p_module).permit(:name, :module_type, :credits)
	  end
end
