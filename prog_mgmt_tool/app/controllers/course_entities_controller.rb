class CourseEntitiesController < ApplicationController
  before_filter :course, :program
  
  def index
  end

  def create
    @course_entity = CourseEntity.new
  	params[:course_entity].permit(:year, :professor, :credits)
    @course_entity.professor = params[:course_entity][:professor]
    @course_entity.credits = params[:course_entity][:credits]
    @course_entity.course_id = params[:course_id]
    @course_entity.year = params[:date][:year]
    @course_entity.save
  	#@course_entity = @course.course_entities.create(params[:course_entity].permit(:year, :professor, :credits))
  	
  	
  	redirect_to program_course_path(@program, @course)
  end

  def show
  	@course_entity = CourseEntity.find(params[:id])
  end

  def new
    @course_entity = CourseEntity.new
  end

  def edit
    @course_entity = CourseEntity.find(params[:id])
  end

  def update
    @course_entity = CourseEntity.find(params[:id])
    
    if params.has_key?(:course_entity)
      @course_entity.update(params[:course_entity].permit(:year, :professor, :credits))
      redirect_to program_course_path(@program, @course)
    else
      render 'edit'
    end
  end

  def destroy
  	@course =  Course.find_by(params[:course_id])
  	@course_entity = @course.course_entities.find(params[:id])
  	@course_entity.destroy
  	redirect_to program_course_path(@program, @course)
  end

  private

    def course
      @course = Course.find(params[:course_id])
    end

    def program
      @program = Program.find(params[:program_id])
    end
end
