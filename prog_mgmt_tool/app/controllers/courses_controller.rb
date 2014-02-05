class CoursesController < ApplicationController
  def new
  	@course = Course.new
  end

  def create
  	@course = Course.new(course_params)
  	@course.save
  	redirect_to @course
  end

  def destroy
  	@course = Course.find(params[:id])
  	@course.destroy
  	redirect_to courses_path
  end

  def edit
  	@course = Course.find(params[:id])
  end

  def update
  	@course = Course.find(params[:id])
  	if params.has_key?(:course)
  		@course.update(params[:course].permit(:name, :sigle))
  		redirect_to @course
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
end
