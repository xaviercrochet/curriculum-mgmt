class CoursesController < ApplicationController
  before_filter :program, :p_module, :catalog

  def new
    @context = context
    @url = index_url(context)
  	@course = @context.courses.new
  end

  
  def create
    @context = context
    @course = @context.courses.create(course_params)
    redirect_to index_url(context)
  end

  def destroy
    @context = context
    @course = @context.courses.find(params[:id])
    @course.destroy
    redirect_to catalog_program_p_module_courses_path(@catalog, @program, @p_module)
  end

  def edit
    state
    @context = context
    @course = @context.courses.find(params[:id])
  end

  def update
    @context = context
    @course = @context.courses.find(params[:id])
    if params.has_key?(:course)
      @course.update(params[:course].permit(:name, :sigle))
      redirect_to catalog_program_p_module_courses_path(@catalog, @program, @p_module)
    else
      render 'edit'
    end
  end

  def show
    @context = context
    @course = @context.courses.find(params[:id])
  end

  def index
    @url = new_url(context)
    
    state
    @context = context
    @courses = @context.courses
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

    def block
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
      nil
    end
    
    def new_url(context)
      if SubModule === context
        new_catalog_program_p_module_sub_module_course_path(@catalog, @program, @p_module, context)
      else
        new_catalog_program_p_module_course_path(@catalog, @program, context)
      end
    end

    def index_url(context)
      if SubModule === context
        catalog_program_p_module_sub_module_course_path(@catalog, @program, @p_module, context)
      else
        catalog_program_p_module_courses_path(@catalog, @program, context)
      end
    end
    def state
      if SubModule === context
        @state = "SubModule"
      else
        @state = "PModule"
      end
    end

    def show_url(context)

      if SubModule === context
        catalog_program_p_module_sub_module_course_path(@catalog, @program, @p_module, context, context.courses)
      else
        catalog_program_p_module_course_path(@catalog, @program, context)
      end
    end
    
    def context
      if params[:p_module_id] and params[:sub_module_id]
        p "SUB MODULE"
        id = params[:sub_module]
        block_type = "SubModule"
        SubModule.find(params[:sub_module_id])
      else
        p "MODULE"
        id = params[:p_module]
        block_type = "PModule"
        PModule.find(params[:p_module_id])
      end
    end


end
