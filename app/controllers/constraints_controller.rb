class ConstraintsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

	def show
	end

	def index
		@course = Course.find(params[:course_id])
		@constraints = @course.constraints
	end

	def destroy
	end
end
