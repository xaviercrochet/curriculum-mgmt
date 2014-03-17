class ProgramsController < ApplicationController
  
  def index
    @catalog = Catalog.find(params[:catalog_id])
    @programs = @catalog.programs
  end

  def destroy
    @catalog = Catalog.find(params[:id])
  	@program = @catalog.programs.find(params[:format])
  	@program.destroy

  	redirect_to catalog_programs_path(@catalog)
  end

  def show
    @program = Program.find(params[:id])
    @catalog = @program.catalog
  end
end
