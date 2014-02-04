class Semester < ActiveRecord::Base
	has_many: course_entities
end
