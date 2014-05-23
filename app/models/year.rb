class Year < ActiveRecord::Base
  belongs_to :student_program
  belongs_to :academic_year
  has_one :first_semester, dependent: :destroy
  has_one :second_semester, dependent: :destroy

  scope :passed, -> {where("status = ?", 2)}
  scope :failed, -> {where("status = ?", 1)}
  scope :current, -> {where("status = ?", 0)}

  def passed?
    self.status.eql? 2
  end

  def migrate(catalog)
    p "migrating year ..."
    missing_courses = []
    missing_courses += self.first_semester.migrate(catalog)
    missing_courses += self.second_semester.migrate(catalog)
    return missing_courses
  end

  def failed?
    self.status.eql? 1
  end

  def pass
    self.status = 2
    self.save 
  end

  def fail
    self.status = 1
    self.save
  end

  def count_credits
    result = 0
    result += first_semester.count_credits
    result += second_semester.count_credits
    return result
  end

  def get_course_objects
    courses = []
    if year.satus.eql? "0"
      courses += self.first_semester.get_courses_objects(self.academic_year.start_year, self.academic_year.end_year) unless  self.first_semester.nil?
      courses += self.second_semester.get_courses_objects(self.academic_year.start_year, self.academic_year.end_year) unless self.second_semester.nil?
    else
      courses += self.first_semester.get_courses_objects_for_migrated_program(self.student_program.program, self.academic_year.start_year, self.academic_year.end_year) unless self.first_semester.nil?
      courses += self.second_semester.get_courses_objects_for_migrated_program(self.student_program.program, self.academic_year.start_year, self.academic_year.end_year) unless self.secnd_semester.nil?
    end
    return courses
  end

end
