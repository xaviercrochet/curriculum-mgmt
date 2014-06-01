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

  def course_present?(course)
    result = self.first_semester.course_present?(course)
    return result unless ! result
    result = self.second_semester.course_present?(course)
    return result
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

  def status_name
    if self.status.eql? 2
      return 'Réussie'
    elsif self.status.eql? 1
      return 'Ratée'
    else
      return 'En cours'
    end
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


  #look for old version of course when checking years that belongs to older programs
  #first case : catalog is the same
  #second case : A catalog migration occurs; we have to check for an older catalog
  def get_old_course_objects(catalog)
    courses = []
    if ! catalog.id.eql? self.student_program.program.catalog
      new_program = catalog.find_program(self.student_program.program.name).first
      courses += self.first_semester.get_old_course_objects_for_migrated_program(new_program, self.academic_year.start_year, self.academic_year.end_year) unless self.first_semester.nil?
      courses += self.second_semester.get_old_course_objects_for_migrated_program(new_program, self.academic_year.start_year, self.academic_year.end_year) unless self.second_semester.nil?
    else
      courses += self.first_semester.get_old_course_objects(self.academic_year.start_year, self.academic_year.end_year) unless  self.first_semester.nil?
      courses += self.second_semester.get_old_course_objects(self.academic_year.start_year, self.academic_year.end_year) unless  self.second_semester.nil?
    end
    return courses
  end

  def get_course_objects
    courses = []
    if self.status.eql? "0"
      courses += self.first_semester.get_courses_objects(self.academic_year.start_year, self.academic_year.end_year) unless  self.first_semester.nil?
      courses += self.second_semester.get_courses_objects(self.academic_year.start_year, self.academic_year.end_year) unless self.second_semester.nil?
    else
      courses += self.first_semester.get_courses_objects_for_migrated_program(self.student_program.program, self.academic_year.start_year, self.academic_year.end_year) unless self.first_semester.nil?
      courses += self.second_semester.get_courses_objects_for_migrated_program(self.student_program.program, self.academic_year.start_year, self.academic_year.end_year) unless self.second_semester.nil?
    end
    return courses
  end

end
