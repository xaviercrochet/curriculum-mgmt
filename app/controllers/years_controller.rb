class YearsController < ApplicationController
  before_action :authenticate_user!


  def new
    @student_program = StudentProgram.find(params[:student_program_id])
    @year = Year.new
    @year.build_first_semester
    @year.build_second_semester
  end

  def create
    @student_program = StudentProgram.find(params[:student_program_id])
    @year = @student_program.years.create
    @first_semester = @year.create_first_semester
    @second_semester = @year.create_second_semester
    params[:first_semester][:ids].each do |id|
      @first_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end unless params[:first_semester].nil?

    params[:second_semester][:ids].each do |id|
      @second_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end unless params[:first_semester].nil?
    
    @student_program.devalidate
    redirect_to @year
  end



  def destroy
    @year = Year.find(params[:id])
    @student_program = @year.student_program
    @year.destroy
    redirect_to student_program_student_program_configure_path(@student_program)
  end

  def show
    @year = Year.find(params[:id])
    @student_program = @year.student_program
  end

  def index
    @student_program = StudentProgram.find(params[:student_program_id])
    @years = @student_program.years
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