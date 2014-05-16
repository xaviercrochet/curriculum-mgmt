class YearsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource


  def new
    @student_program = StudentProgram.find(params[:student_program_id])
    @year = Year.new
    @year.build_first_semester
    @year.build_second_semester
  end

  def create
    @student_program = StudentProgram.find(params[:student_program_id])
    @year = @student_program.years.create(year_params)
    @first_semester = @year.create_first_semester
    @second_semester = @year.create_second_semester
    params[:first_semester][:ids].each do |id|
      @first_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end unless params[:first_semester].nil?

    params[:second_semester][:ids].each do |id|
      @second_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end unless params[:second_semester].nil?
    
    @student_program.set_count(-1)
    @student_program.devalidate
    redirect_to @year
  end

  def pass
    @year = Year.find(params[:year_id])
    @year.pass
    redirect_to user_manage_years_path(current_user)
  end

  def edit
    @year = Year.find(params[:id])
  end

  def update
    @year = Year.find(params[:id])
    @year.update(year_params)
    @year.first_semester.courses = []
    @year.second_semester.courses = []
    params[:first_semester][:ids].each do |id|
      @year.first_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end unless params[:first_semester].nil?

    params[:second_semester][:ids].each do |id|
      @year.second_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end unless params[:second_semester].nil?

    if current_user.admin?
      @year.fail
      redirect_to user_manage_years_path(current_user)
    else
      redirect_to student_program_student_program_configure_path(@year.student_program)
    end
  end

  def fail
    @year = Year.find(params[:year_id])
    @year.fail
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

  def year_params
    params.require(:year).permit(:academic_year_id)
  end
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