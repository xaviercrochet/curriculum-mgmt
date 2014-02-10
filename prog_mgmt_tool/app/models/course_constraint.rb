class CourseConstraint < ActiveRecord::Base
	belongs_to :program
	belongs_to :course

def get_first_course
	Course.find(self.first_course_id)
end

def get_second_course
	Course.find(self.second_course_id)
end


end
