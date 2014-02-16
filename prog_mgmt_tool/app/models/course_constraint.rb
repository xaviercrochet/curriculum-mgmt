class CourseConstraint < ActiveRecord::Base
	belongs_to :course

	def second_course
		Course.find(self.second_course_id)
	end
end
