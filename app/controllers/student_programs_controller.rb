class StudentProgramsController < ApplicationController
  def new
    @catalog = Catalog.last #Remplace by Catalog.MAIN
    @student_program = StudentProgram.new
  end

  def create
    @program = Program.find(params[:student_program][:program_id])
    @student_program = @program.student_programs.create
    redirect_to @student_program
  end

  def destroy
    @student_program = StudentProgram.find(params[:id])
    @student_program.destroy
    redirect_to student_programs_path
  end

  def show
    @student_program = StudentProgram.find(params[:id])
    @back = back
    record_history
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
    @corequisites = Course.find(@logs[:corequisites_missing])
    @back = back
    record_history
  end

private

  def record_history
    session[:history] ||= []
    session[:history].push request.url
    session[:history] = session[:history].last(10)
  end

  def back
    session[:history].pop
  end

end
