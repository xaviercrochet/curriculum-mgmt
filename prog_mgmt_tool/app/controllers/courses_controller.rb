class CoursesController < ApplicationController


 def destroy
    @course = Course.find(params[:id])
    @p_module = @course.p_module
    @course.destroy
    redirect_to p_module_courses_path(@p_module)
  end

  def show
    @course = Course.find(params[:id])
    @catalog = @course.catalog
    @back = back
  end

  def index
    @context = context
    @courses = @context.courses
  end

private
	def course_params
		params.require(:course).permit(:name, :sigle)
	end
  
  def record_history
    session[:history] ||= []
    session[:history].push request.url
    session[:history] = session[:history].last(10)
  end

  def back
    session[:history].pop
  end

  def context
    if params[:p_module_id]
      block_type = "PModule"
      PModule.find(params[:p_module_id])
    elsif params[:program_id]
      block_type = "Program"
      Program.find(params[:program_id])
    elsif params[:catalog_id]
      block_type = "Catalog"
      Catalog.find(params[:catalog_id])
    end
  end
end