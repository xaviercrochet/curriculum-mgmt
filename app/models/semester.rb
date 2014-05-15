class Semester < ActiveRecord::Base
  has_and_belongs_to_many :courses
  belongs_to :year

  def get_courses_objects(passed)
    courses = []
    self.courses.each do |course|
      courses << course.get_course_object(passed)
    end
    return courses
  end

  def count_credits
    result = 0
    self.courses.each do |course|
      result += course.credits.to_i
    end
    return result
  end
end
