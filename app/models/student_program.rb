require 'constraints_checker/catalog'
require 'constraints_checker/constraints/property_constraint'

class StudentProgram < ActiveRecord::Base
  belongs_to :program
  belongs_to :user
  has_many :years, dependent: :destroy
  has_many :validations, dependent: :destroy
  has_and_belongs_to_many :p_modules

  def check_constraints
    c = ConstraintsChecker::Catalog.new(id: self.id, name: "Student Program")
    c.add_constraint(ConstraintsChecker::Constraints::Min.new(c, program.min))
    c.add_constraint(ConstraintsChecker::Constraints::Max.new(c, program.max))
    
    mandatories = program.mandatory_courses

    mandatories.each do |m|
      c.add_constraint(ConstraintsChecker::Constraints::MandatoryCourse.new(c, m.id))
    end

    self.p_modules.each do |m|
      c.add_children(m.get_p_module_object(m.mandatory?))
    end
    
    courses = []
    
    self.years.each do |year|
      courses = courses + year.get_course_objects
    end

    courses.each do |course|
      p_module = c.find_p_module(course.parent_id)
      
      if p_module.nil?
        c.add_children(course)
      
      else
        p_module.add_children(course)
      end
    end
    
    return c.check_constraints
  end

  def first_semester_available_courses
    courses = self.program.first_semester_courses
    self.years.each do |year|
      courses -= year.first_semester.courses
      courses -= year.second_semester.courses
    end
    return courses
  end

  def second_semester_available_courses
    courses = self.program.second_semester_courses
    self.years.each do |year|
      courses -= year.first_semester.courses
      courses -= year.second_semester.courses
    end
    return courses
  end

  def is_p_module_present?(p_module)
    self.p_modules.where(id: p_module.id).count > 0
  end

  def first_semester_mandatory_courses
    self.program.first_semester_mandatory_courses
  end

  def second_semester_mandatory_courses
    self.program.second_semester_mandatory_courses
  end

  def first_semester_optional_courses
    self.program.first_semester_optional_courses
  end

  def second_semester_optional_courses
    self.program.second_semester_optional_courses
  end

  def get_missing_mandatory_courses(logs)
    mandatories_id = []
    mandatories_id  += logs[:mandatory_courses_missing]
    logs[:courses_missing_in_module].each do |key, value|
      mandatories_id += value
    end 
    return Course.find(mandatories_id)
  end

  def get_missing_prerequisites(logs)
    Course.find(logs[:prerequisites_missing])
  end

  def get_missing_corequisites(logs)
    Course.find(logs[:corequisites_missing])
  end

  def get_missing_or_corequisites(logs)
    or_corequisites = []
    logs[:or_corequisites_missing].each do |o|
      or_corequisites << Course.find(o)
    end
    return or_corequisites
  end

  def get_missing_xor_corequisites(logs)
    xor_corequisites = []
    logs[:xor_corequisites_missing].each do |o|
      xor_corequisites << Course.find(o)
    end
    return xor_corequisites
  end

  def get_missing_or_prerequisites(logs)
    or_prerequisites = []
    logs[:or_prerequisites_missing].each do |o|
      or_prerequisites << Course.find(o)
    end
    return or_prerequisites
  end

  def get_missing_xor_prerequisites(logs)
    xor_prerequisites = []
    logs[:xor_prerequisites_missing].each do |o|
      xor_prerequisites << Course.find(o)
    end
    return xor_prerequisites
  end


  def validation_request_already_sent
    self.validations.count > 0
  end

  def validate
    self.validated = true
    self.save
  end

  def devalidate
    self.validated = false
    self.save
  end

  def state
    self.validated or self.validation_request_already_sent
  end
end
