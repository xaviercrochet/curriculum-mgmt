class Year < ActiveRecord::Base
  belongs_to :student_program
  belongs_to :academic_year
  has_one :first_semester, dependent: :destroy
  has_one :second_semester, dependent: :destroy

  def passed?
    self.status.eql? "2"
  end

  def failed?
    self.status.eql? "1"
  end 

  def count_credits
    result = 0
    result += first_semester.count_credits
    result += second_semester.count_credits
    return result
  end

  def get_course_objects
    courses = []
    courses = courses + self.first_semester.get_courses_objects(self.passed) unless  self.first_semester.nil?
    courses = courses + self.second_semester.get_courses_objects(self.passed) unless self.second_semester.nil?
    return courses
  end

end
