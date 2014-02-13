class ProgramsController < ApplicationController
  before_filter :catalog
  
  def index
  	@programs = Program.where(catalog_id: @catalog.id)
  end


  def new
    @program = Program.new
  end

  def destroy
  	@program = @catalog.programs.find(params[:id])
  	@program.destroy

  	redirect_to catalog_programs_path(@catalog)
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
  	@program = @catalog.programs.find(params[:id])

  	if @program.update(params[:program].permit(:cycle, :program_type, :credits))
  		redirect_to catalog_program_path(@catalog, @program)
  	else
  		render 'edit'
  	end
  end

  def create
    @program = @catalog.programs.create(program_params)
  	redirect_to catalog_program_path(@catalog, @program)
  end

  def show
  	@program = Program.find(params[:id])
  end

 	private
 		def program_params
 			params.require(:program).permit(:cycle, :program_type, :credits)
 		end

    def catalog
      @catalog = Catalog.find(params[:catalog_id])
    end
end
