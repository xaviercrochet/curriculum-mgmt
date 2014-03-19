class ConstraintsController < ApplicationController

	def show
	end

	def index
		@course = Course.find(params[:course_id])
		@binary_corequisites = @course.binary_corequisites
		@binary_prerequisites = @course.binary_prerequisites
		@xor_corequisites =  @course.xor_corequisites
		@xor_prerequisites = @course.xor_prerequisites
		@or_corequisites =  @course.or_corequisites
		@or_prerequisites = @course.or_prerequisites
	end

	def destroy
	end
end
