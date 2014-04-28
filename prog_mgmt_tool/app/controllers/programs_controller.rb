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
    @p_modules = @catalog.p_modules.without_parent
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
    params[:program][:p_modules][:ids].each do |value|
      @program.p_modules << PModule.find(value.to_i) unless value.eql? "0"
    end
    params[:program][:courses][:ids].each do |value|
      @program.courses << Course.find(value.to_i) unless value.eql? "0"
    end
    p params.inspect
    redirect_to @program
  end

  def show
    @program = Program.find(params[:id])
    @catalog = @program.catalog
  end
end
