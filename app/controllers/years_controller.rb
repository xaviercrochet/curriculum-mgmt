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
    @back = back
    record_history
  end

  def index
    @student_program = StudentProgram.find(params[:student_program_id])
    @years = @student_program.years
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