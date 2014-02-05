class ProgramsController < ApplicationController
  def index
  	@programs = Program.all
  end


  def new
    @program = Program.new
  end

  def destroy
  	@program = Program.find(params[:id])
  	@program.destroy

  	redirect_to programs_path
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
  	@program = Program.find(params[:id])

  	if @program.update(params[:program].permit(:cycle, :program_type, :credits))
  		redirect_to @program
  	else
  		render 'edit'
  	end
  end

  def create
  	@program = Program.new(program_params)
  	@program.save
  	redirect_to @program
  end

  def show
  	@program = Program.find(params[:id])
  end

 	private
 		def program_params
 			params.require(:program).permit(:cycle, :program_type, :credits)
 		end
end
