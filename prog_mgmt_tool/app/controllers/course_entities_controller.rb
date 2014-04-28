class CourseEntitiesController < ApplicationController
  before_filter :course, :program, :catalog, :p_module
  
  def index
    @course_entities = @course.course_entities
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
  	
  	redirect_to catalog_program_p_module_course_course_entity_path(@catalog, @program, @p_module, @course, @course_entity)
  end

  def show
  	@course_entity = @course.course_entities.find(params[:id])
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
      params[:course_entity].permit(:year, :professor, :credits)
      @course_entity.professor = params[:course_entity][:professor]
      @course_entity.credits = params[:course_entity][:credits]
      @course_entity.course_id = params[:course_id]
      @course_entity.year = params[:date][:year]
      @course_entity.save
      redirect_to catalog_program_p_module_course_course_entity_path(@catalog, @program, @p_module, @course, @course_entity)
    else
      render 'edit'
    end
  end

  def destroy
  	@course_entity = @course.course_entities.find(params[:id])
  	@course_entity.destroy
  	redirect_to catalog_program_p_module_course_course_entities_path(@catalog, @program, @p_module, @course)
  end

  private

    def course_entity_params

      params.require(:course_entity).permit(:year, :professor, :credits)
      
    end

    def catalog
      @catalog = Catalog.find(params[:catalog_id])
    end

    def p_module
      @p_module = PModule.find(params[:p_module_id])
    end

    def course
      @course = Course.find(params[:course_id])
    end

    def program
      @program = Program.find(params[:program_id])
    end
end
