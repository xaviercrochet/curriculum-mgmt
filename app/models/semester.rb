class Semester < ActiveRecord::Base
  has_and_belongs_to_many :courses
  belongs_to :year

  def get_courses_objects
    passed = self.year.passed?
    courses = []
    self.courses.each do |course|
      courses << course.get_course_object(passed)
    end
    return courses
  end
end
