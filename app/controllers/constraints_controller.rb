class ConstraintsController < ApplicationController
  before_action :authenticate_user!

	def show
	end

	def index
		@course = Course.find(params[:course_id])
		@constraints = @course.constraints
	end

	def destroy
	end
end
