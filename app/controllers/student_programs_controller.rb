class StudentProgramsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    if current_user.catalog.nil?
      catalog = Catalog.main.first
      if catalog.nil?
        catalog = Catalog.old.first
      end
      current_user.catalog = catalog
      current_user.save
    end

    @catalog = current_user.catalog
    current_user.student_programs.new
  end

  def update_program
    @student_program = StudentProgram.find(params[:student_program_id])
    @program  = Program.find(params[:student_program][:program_id])
    results = @student_program.migrate_program(@program)
    @student_program.uncheck
    redirect_to @student_program
  end

  def create
    @program = Program.find(params[:student_program][:program_id])
    @student_program = current_user.student_programs.create
    @student_program.program = @program
    @student_program.save
    @student_program.create_justification
    redirect_to @student_program
  end

  def configure
    @student_program = StudentProgram.includes(years: :academic_year).find(params[:student_program_id])
    @years = @student_program.years
  end

  def edit
    @student_program = StudentProgram.includes(program: [catalog: :academic_year]).find(params[:id])
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
    @student_program = StudentProgram.includes(program: [catalog: :academic_year]).find(params[:id])
    @student_program.p_modules = []
    params[:mandatory_modules][:ids].each do |id|
      @student_program.p_modules << PModule.find(id.to_i) unless id.eql? "0"
    end unless params[:mandatory_modules].nil?

    params[:optional_modules][:ids].each do |id|
      @student_program.p_modules << PModule.find(id.to_i) unless id.eql? "0"
    end unless params[:optional_modules].nil?
    @student_program.uncheck
    redirect_to student_program_student_program_configure_path(@student_program)
  end

  def show
    @student_program = StudentProgram.includes(years: [first_semester: :courses, second_semester: :courses]).find(params[:id])
  end

  def index
    @student_programs = current_user.student_programs.includes(:program, :justification)
  end

  def check
    @student_program = StudentProgram.includes(justification: [constraint_exceptions: :entity], years: [first_semester: :courses, second_semester: :courses], program: [p_modules: :sub_modules]).find(params[:student_program_id])
    @program = @student_program.program
    if ! @student_program.checked?
      @student_program.check_constraints
    end
    @justification  = @student_program.justification
    @constraint_exceptions = @justification.constraint_exceptions

  end

  def new_validation
    @student_program = StudentProgram.find(params[:student_program_id])
    @student_program.create_validation
    @student_program.unvalidate
    @student_program.uncheck
    redirect_to @student_program
  end

private
  def student_program_params
    params.require(:student_program).permit()
  end

end
