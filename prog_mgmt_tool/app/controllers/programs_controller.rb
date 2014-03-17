class ProgramsController < ApplicationController
  
  def index
    @catalog = Catalog.find(params[:catalog_id])
    @programs = @catalog.programs
  end


  def new
    @program = Program.new
  end

  def destroy
  	@program = @catalog.programs.find(params[:format])
  	@program.destroy

  	redirect_to catalog_programs_path(@catalog)
  end

  def edit
    @program = catalog.programs.find(params[:format])
  end

  def update
  	@program = @catalog.programs.find(params[:format])

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
    @catalog = @program.catalog
  end

 	private
 		def program_params
 			params.require(:program).permit(:cycle, :program_type, :credits)
 		end

    def catalog
      if params[:catalog_id]
        @catalog = Catalog.find(params[:catalog_id])
      
      else
        @catalog = Catalog.find(params[:id])
      end
    end
end
