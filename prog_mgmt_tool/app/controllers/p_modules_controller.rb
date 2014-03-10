class PModulesController < ApplicationController
  before_filter :program

  def index
  	@p_modules = @program.p_modules
	end

  def show
  	@p_module = @program.p_modules.find(params[:format])
  end

  def update
  	@p_module = @program.p_modules.find(params[:format])

  	if @p_module.update(params[:p_module].permit(:name, :module_type, :credits))
  		redirect_to catalog_program_p_module_path(@catalog, @program, @p_module)
  	else
  		render 'edit'
  	end
  end

  def destroy
  	@p_module = @program.p_modules.find(params[:format])
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
  	@p_module = @program.p_modules.find(params[:format])
  end

  private
		def program
	  	@program = Program.find(params[:id])
	  end

	  def p_module_params
	  	params.require(:p_module).permit(:name, :module_type, :credits)
	  end
end
