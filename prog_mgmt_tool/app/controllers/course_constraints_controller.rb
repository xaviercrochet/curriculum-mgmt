class CourseConstraintsController < ApplicationController
	before_filter :program, :courses
	
	def index
		@course_constraints = Program.find(params[:program_id]).course_constraints
	end

	def new
		@course_constraint = CourseConstraint.new
	end

	def create
		@first_course = Course.find(params[:course_constraint][:first_course_id])
		@second_course = Course.find(params[:course_constraint][:second_course_id])
		@course_constraint = CourseConstraint.new
		params[:course_constraint].permit(:first_course_id, :second_course_id, :constraint_type)
		@course_constraint.first_course_id = params[:course_constraint][:first_course_id]
		@course_constraint.first_course_sigle = @first_course.sigle
		@course_constraint.second_course_id = params[:course_constraint][:second_course_id]
		@course_constraint.second_course_sigle = @second_course.sigle
		@course_constraint.program_id = params[:program_id]
		@course_constraint.constraint_type = params[:course_constraint][:constraint_type]
		@course_constraint.save
		redirect_to program_course_constraints_path(@program)
	end

	def show
		@first_course = Course.find(params[:first_course_id])
		@second_course = Course.find(params[:second_course_id])
		@course_constraint = @program.course_constraints.find(params[:id])

	end

	private

		def program
			@program = Program.find(params[:program_id])
		end

		def courses
			@courses = Course.all
		end
end
