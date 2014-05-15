class Semester < ActiveRecord::Base
  has_and_belongs_to_many :courses
  belongs_to :year

  def get_courses_objects(start_year, end_year)
    courses = []
    self.courses.each do |course|
      courses << course.get_course_object(start_year, end_year)
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
