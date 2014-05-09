class StudentProgramsController < ApplicationController
  before_filter :record_history

  def new
    @catalog = Catalog.last #Remplace by Catalog.MAIN
    @student_program = StudentProgram.new
  end

  def create
    @program = Program.find(params[:student_program][:program_id])
    @student_program = @program.student_programs.create
    redirect_to @student_program
  end

  def configure
    @student_program = StudentProgram.find(params[:student_program_id])
    @years = @student_program.years
    @back = back
  end

  def destroy
    @student_program = StudentProgram.find(params[:id])
    @student_program.destroy
    redirect_to student_programs_path
  end

  def update
    @student_program = StudentProgram.find(params[:id])
    @student_program.p_modules = []
    params[:mandatory_modules][:ids].each do |id|
      @student_program.p_modules << PModule.find(id.to_i) unless id.eql? "0"
    end unless params[:mandatory_modules].nil?

    params[:optional_modules][:ids].each do |id|
      @student_program.p_modules << PModule.find(id.to_i) unless id.eql? "0"
    end unless params[:optional_modules].nil?
    
    redirect_to student_program_student_program_configure_path(@student_program)
  end

  def show
    @student_program = StudentProgram.find(params[:id])
  end

  def index
    @student_programs = StudentProgram.all
    
    @back = back
    record_history
  end

  def check
    @student_program = StudentProgram.find(params[:student_program_id])
    @logs = @student_program.check_constraints
    @prerequisites = Course.find(@logs[:"prerequisites_missing"])

    #TODO => Move all the logic to the model
    mandatories_id = []
    mandatories_id  += @logs[:mandatory_courses_missing]
    @logs[:courses_missing_in_module].each do |key, value|
      mandatories_id += value
    end 
    @mandatories = Course.find(mandatories_id)
    @corequisites = Course.find(@logs[:corequisites_missing])
    @or_corequisites = []
    @logs[:or_corequisites_missing].each do |o|
      @or_corequisites << Course.find(o)
    end

    @or_prerequisites = []
    @logs[:or_prerequisites_missing].each do |o|
      @or_prerequisites << Course.find(o)
    end

    @xor_corequisites = []
    @logs[:xor_corequisites_missing].each do |o|
      @xor_corequisites << Course.find(o)
    end

    @xor_prerequisites = []
    @logs[:xor_prerequisites_missing].each do |o|
      @xor_prerequisites << Course.find(o)
    end


  end

  def new_validation
    @student_program = StudentProgram.find(params[:student_program_id])
    @student_program.validations.create
    redirect_to @student_program
  end

private

  def record_history
    session[:history] ||= []
    session[:history].push request.url
    session[:history] = session[:history].last(10)
  end

  def back
    session[:history].pop unless session.nil?
    root_path if session.nil?
  end

end
