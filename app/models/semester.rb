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

  def migrate(catalog)
    new_courses = []
    courses_not_found = []
    self.courses.each do |course|
      new_course = Course.find_by_propert("SIGLE", course.name, catalog)
      if new_course.nil?
         courses_not_found << course
      else
        new_courses << new_course
      end
    end
    return courses_not_found
  end

  def count_credits
    result = 0
    self.courses.each do |course|
      result += course.credits.to_i
    end
    return result
  end
end
