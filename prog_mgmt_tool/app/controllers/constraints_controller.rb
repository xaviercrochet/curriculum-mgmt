class ConstraintsController < ApplicationController

	def show
	end

	def index
		@course = Course.find(params[:course_id])
		@binary_corequisites = @course.binary_corequisites
		@binary_prerequisites = @course.binary_prerequisites
	end

	def destroy
	end
end
