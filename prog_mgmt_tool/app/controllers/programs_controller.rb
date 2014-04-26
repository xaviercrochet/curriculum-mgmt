class ProgramsController < ApplicationController
  
  def index
    @catalog = Catalog.find(params[:catalog_id])
    @programs = @catalog.programs
  end

  def destroy
    @program = Program.find(params[:id])
    @catalog = @program.catalog
    @program.destroy
    redirect_to catalog_programs_path(@catalog)
  end

  def new
    @catalog = Catalog.find(params[:catalog_id])
    @program = Program.new
    2.times do
      property = @program.properties.build
    end
  end
  
  def create
    @catalog = Catalog.find(params[:catalog_id])
    @program = @catalog.programs.create
    @program.properties.create(p_type: "NAME", value: params[:program][:property][:name])
    @program.properties.create(p_type: "CREDITS", value: params[:program][:property][:credits])
    redirect_to @program
  end

  def show
    @program = Program.find(params[:id])
    @catalog = @program.catalog
  end
end
