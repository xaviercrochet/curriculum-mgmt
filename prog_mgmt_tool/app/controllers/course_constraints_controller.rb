class CourseConstraintsController < ApplicationController
	before_filter :program, :course, :courses
	
	def index
		#@course_constraints = CourseConstraint.where(:course_id => @course.id).includes(:second_course)
		@course_constraints = CourseConstraint.where(course_id: @course.id).joins("INNER JOIN courses ON courses.id = course_constraints.second_course_id")
	end

	def new
		@course_constraint = CourseConstraint.new
	end

	def create
		@course_constraint = CourseConstraint.new
		params[:course_constraint].permit(:second_course_id, :constraint_type)
		@course_constraint.course_id = @course.id
		@course_constraint.program_id = @program.id
		@course_constraint.second_course_id = params[:course_constraint][:second_course_id]
		@course_constraint.constraint_type = params[:course_constraint][:constraint_type]
		@course_constraint.save		
		#@first_course = Course.find(params[:course_constraint][:first_course_id])
		#@second_course = Course.find(params[:course_constraint][:second_course_id])
		#@course_constraint = CourseConstraint.new
		#
		#@course_constraint.first_course_id = params[:course_constraint][:first_course_id]
		#@course_constraint.first_course_sigle = @first_course.sigle
		#@course_constraint.second_course_id = params[:course_constraint][:second_course_id]
		#@course_constraint.second_course_sigle = @second_course.sigle
		#@course_constraint.program_id = params[:program_id]
		#@course_constraint.constraint_type = params[:course_constraint][:constraint_type]
		#@course_constraint.save
		redirect_to program_course_course_constraints_path(@program, @course)
	end

	def show
		@second_course = Course.find(params[:second_course_id])
		@course_constraint = @program.course_constraints.find(params[:id])

	end

	private

		def program
			@program = Program.find(params[:program_id])
		end

		def course
			@course = Course.find(params[:course_id])
		end

		def courses
			@courses = Course.where(:program_id => params[:program_id])
		end
end
