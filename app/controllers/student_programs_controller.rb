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
  end

  def index
    @student_programs = StudentProgram.all
  end

private

end
