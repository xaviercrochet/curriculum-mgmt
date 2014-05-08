class Year < ActiveRecord::Base
  belongs_to :student_program
  has_one :first_semester
  has_one :second_semester

  def passed?
    self.passed
  end 

  def get_course_objects
    courses = []
    courses = courses + self.first_semester.get_courses_objects unless  self.first_semester.nil?
    courses = courses + self.second_semester.get_courses_objects unless self.second_semester.nil?
    return courses
  end

end
