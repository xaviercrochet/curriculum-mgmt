class PModulesController < ApplicationController

  def index
    @program = Program.find(params[:program_id])
  	@p_modules = @program.p_modules
	end

  def show
  	@p_module = PModule.find(params[:id])
    @program = @p_module.program
  end

  def destroy
    @program = Program.find(params[:id])
  	@p_module = @program.p_modules.find(params[:format])
  	@p_module.destroy
  	redirect_to program_p_modules_path(@program)
  end
end
