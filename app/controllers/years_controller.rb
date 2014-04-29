class YearsController < ApplicationController
  def new
    @student_program = StudentProgram.find(params[:student_program_id])
    @year = Year.new
    2.times do
      @year.semesters.build
    end
  end

  def create
    @student_program = StudentProgram.find(params[:student_program_id])
    @year = @student_program.years.create
    @first_semester = @year.semesters.create(slot: 1)
    @second_semester = @year.semesters.create(slot: 2)
    params[:q1][:ids].each do |id|
      @first_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end

    params[:q2][:ids].each do |id|
      @second_semester.courses << Course.find(id.to_i) unless id.eql? "0"
    end
    
    redirect_to @year
  end

  def update
  end

  def destroy
  end

  def show
    @year = Year.find(params[:id])
    @back = back
    record_history
  end

  def index
    @student_program = StudentProgram.find(params[:student_program_id])
    @years = @student_program.years
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