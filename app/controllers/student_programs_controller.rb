class StudentProgramsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    @catalog = current_user.catalog
    current_user.student_programs.new
  end

  def update_program
    @student_program = StudentProgram.find(params[:student_program_id])
    @program  = Program.find(params[:student_program][:program_id])
    results = @student_program.migrate_program(@program)
    p results
    redirect_to @student_program
  end

  def create
    @program = Program.find(params[:student_program][:program_id])
    @student_program = current_user.student_programs.create
    @student_program.program = @program
    @student_program.save
    redirect_to @student_program
  end

  def configure
    @student_program = StudentProgram.find(params[:student_program_id])
    @years = @student_program.years
  end

  def edit
    @student_program = StudentProgram.find(params[:id])
  end

  def status
    @student_program = StudentProgram.find(params[:student_program_id])
    @logs = @student_program.check_constraints
    @program = @student_program.program
  end

  def destroy
    @student_program = StudentProgram.find(params[:id])
    @student_program.destroy
    redirect_to user_student_programs_path(current_user)
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
    
    @student_program.set_count(-1)
    redirect_to student_program_student_program_configure_path(@student_program)
  end

  def show
    @student_program = StudentProgram.find(params[:id])
  end

  def index
    @student_programs = current_user.student_programs
  end

  def check
    @student_program = StudentProgram.find(params[:student_program_id])
    @program = @student_program.program
    if ! @student_program.checked?
      @student_program.check_constraints
    end
    @justification  = @student_program.justification
  end

  def new_validation
    @student_program = StudentProgram.find(params[:student_program_id])
    @student_program.create_validation
    redirect_to @student_program
  end

private
  def student_program_params
    params.require(:student_program).permit()
  end

end
