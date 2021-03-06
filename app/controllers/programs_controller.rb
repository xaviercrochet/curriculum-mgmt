class ProgramsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @catalog = Catalog.find(params[:catalog_id])
    @programs = @catalog.programs.includes(:courses, p_modules: [:courses, {sub_modules: :courses}])
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
    @properties_type = ["credits", "name"]
  end
  
  def create
    @properties_type = ["credits", "name"]
    @catalog = Catalog.find(params[:catalog_id])
    @program = @catalog.programs.create(program_params)
    if @program.errors.any? 
      render action: :new
    else
      params[:program][:p_modules][:ids].each do |value|
        @program.p_modules << PModule.find(value.to_i) unless value.eql? "0"
      end
      params[:program][:courses][:ids].each do |value|
        @program.courses << Course.find(value.to_i) unless value.eql? "0"
      end
      redirect_to @program
    end
  end

  def show
    @program = Program.find(params[:id])
    @catalog = @program.catalog
  end

private

  def program_params
    params.require(:program).permit(properties_attributes: [:p_type, :value])
  end
end
