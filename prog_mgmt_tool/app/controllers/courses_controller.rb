class CoursesController < ApplicationController
  before_filter :catalog

  def new
    @context = context
    @course = @context.courses.new
  end

  
  def create
    @context = context
    @course = @context.courses.new
    @course.build(params[:course])
    @course.catalog_id = @catalog.id
    @course.save
    redirect_to index_url(context)
  end

  def destroy
    @course = Course.find(params[:id])
    @context = @course.block
    @course.destroy
    redirect_to index_url(@context)
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
    @course = Course.find(params[:id])
    @block = @course.block
  end

  def index
    @context = context
    @courses = @context.courses
  end

  private
  	def course_params
  		params.require(:course).permit(:name, :sigle)
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
        sub_module_courses_path(context)
      
      elsif PModule === context
        p_module_courses_path(context)

      elsif Program === context
        program_courses_path(context)
      
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
      if params[:sub_module_id]
        p "SUB MODULE"
        id = params[:sub_module]
        block_type = "SubModule"
        SubModule.find(params[:sub_module_id])
      elsif params[:p_module_id]
        p "MODULE"
        id = params[:p_module]
        block_type = "PModule"
        PModule.find(params[:p_module_id])
      elsif params[:program_id]
        p "Program"
        id = params[:program_id]
        block_type = "Program"
        Program.find(params[:program_id])
      end
    end

    def catalog
      
      if params[:sub_module_id]
        @catalog = SubModule.find(params[:sub_module_id]).p_module.program.catalog

      elsif params[:p_module_id]
        @catalog = PModule.find(params[:p_module_id]).program.catalog

      elsif params[:program_id]
        @catalog = Program.find(params[:program_id]).catalog
      
      end
    end


end
