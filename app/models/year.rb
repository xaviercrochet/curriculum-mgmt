class Year < ActiveRecord::Base
  belongs_to :student_program
  has_many :semesters

  validate :year_can_only_have_on_first_semester
  validate :year_can_only_have_on_second_semester
  
  def first_semester
    self.semesters.where(slot: 1).first
  end

  def second_semester
    self.semesters.where(slot: 2).first
  end

  def passed?
    self.passed
  end

  def year_can_only_have_on_first_semester
    errors.add(:semester, "Too Many First Semesters") if self.semesters.where(slot: 1).count > 1
  end
  
  def year_can_only_have_on_second_semester
    errors.add(:semester, "Too Many Second Semesters")  if self.semesters.where(slot: 2).count > 1
  end 

  def get_course_objects
    courses = []
    courses = courses + self.first_semester.get_courses_objects
    courses = courses + self.second_semester.get_courses_objects
    return courses
  end

end
