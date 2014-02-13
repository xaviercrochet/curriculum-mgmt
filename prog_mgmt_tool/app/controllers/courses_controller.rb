class CoursesController < ApplicationController
  before_filter :program, :p_module, :catalog

  def new
  	@course = Course.new
  end

  
  def create
    @course = @p_module.courses.create(course_params)
    redirect_to catalog_program_p_module_courses_path(@catalog, @program, @p_module)
  end

  def destroy
    @course = @p_module.courses.find(params[:id])
    @course.destroy
    redirect_to catalog_program_p_module_courses_path(@catalog, @program, @p_module)
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = @p_module.courses.find(params[:id])
    if params.has_key?(:course)
      @course.update(params[:course].permit(:name, :sigle))
      redirect_to catalog_program_p_module_courses_path(@catalog, @program, @p_module)
    else
      render 'edit'
    end
  end

  def show
    @course = @p_module.courses.find(params[:id])
  end

  def index
    @courses = @p_module.courses
  end

  private
  	def course_params
  		params.require(:course).permit(:name, :sigle)
  	end

    def program
      @program  = Program.find(params[:program_id])
    end

    def p_module
      @p_module = PModule.find(params[:p_module_id])
    end

    def catalog
      @catalog = Catalog.find(params[:catalog_id])
    end


end
