class CoursesController < ApplicationController
  before_filter :program

  def new
  	@course = Course.new
  end

  def create
  	@course = Course.new(course_params)
    @course.program_id = params[:program_id]
  	@course.save
  	redirect_to program_course_path(@program, @course)
  end

  def destroy
  	@course = Course.find(params[:id])
  	@course.destroy
  	redirect_to program_courses_path(@program)
  end

  def edit
  	@course = Course.find(params[:id])
  end

  def update
  	@course = Course.find(params[:id])
  	if params.has_key?(:course)
  		@course.update(params[:course].permit(:name, :sigle))
  		redirect_to program_courses_path(@program)
  	else
  		render 'edit'
  	end
  end

  def show
  	@course = Course.find(params[:id])
  end

  def index
  	@courses = Course.all
  end

  private
  	def course_params
  		params.require(:course).permit(:name, :sigle)
  	end

  def program
    @program  = Program.find(params[:program_id])
  end
end
