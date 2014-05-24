require 'constraints_checker/catalog'
require 'constraints_checker/constraints/property_constraint'

class StudentProgram < ActiveRecord::Base
  belongs_to :program
  belongs_to :user
  has_many :years, dependent: :destroy
  has_one :validation, dependent: :destroy
  has_one :justification, dependent: :destroy
  has_and_belongs_to_many :p_modules

  def can_migrate?
    self.program.catalog.find_updated_version.size > 0
  end

  def count_credits_for_module(p_module)
    result = 0
    sub_module_ids = []
    p_module.sub_modules.each do |m|
      sub_module_ids << m.id
    end

    years.each do |year|
      courses = year.first_semester.courses.where(p_module_id: p_module.id)
      courses += year.second_semester.courses.where(p_module_id: p_module.id)
      courses.each do |course|
        result += course.credits.to_i
      end
      sub_module_ids.each do |id|
        courses = year.first_semester.courses.where(p_module_id: id)
        courses += year.second_semester.courses.where(p_module_id: id)
        courses.each do |course|
          result += course.credits.to_i
        end
      end
    end
    return result
  end


  def module_present?(p_module)
    self.p_modules.where(id: p_module.id).count > 0
  end

  def check
    self.checked = true
    self.save
  end

  def course_present?(course)
    self.years.each do |year|
      result = year.course_present?(course)
      return result unless ! result
    end
    return false
  end


  def uncheck
    self.checked = false
    self.save
  end

  def checked?
    self.checked.eql? true
  end

  def migrate_program(program)
    p "migrating program ..."
    missing_courses = []
    self.years.current.each do |year|
      missing_courses += year.migrate(program.catalog)
    end
    self.program = program
    self.save
    return missing_courses
  end

  def find_updated_programs
    catalog_candidates = self.program.catalog.find_updated_version
    results = []
    catalog_candidates.each do |catalog|
      program_candidates = catalog.find_program(self.program.name)
      if program_candidates.size > 0
        results += program_candidates
      end
    end
    return results
  end


  def check_constraints

    if self.justification.nil?
      self.create_justification
    end
    self.justification.constraint_exceptions.each do |c|
      c.destroy
    end
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

    self.program.p_modules.mandatory.each do |m|
      if ! self.module_present?(m)
        c.add_children(m.get_p_module_object(true))
      end
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
        p "PMODULE FOUND"
        p_module.add_children(course)
      end
    end
    results = c.check
    create_constraint_exceptions(results)
    self.check
    results
  end

  def can_justify?
    self.checked
  end

  def edit_or_new_justification_link
    link = nil
    if self.justification.nil?
      link = new_student_program_justification_path(self)
    else
      link = edit_justification_path(self.justification)
    end
    return link
  end

  def count_credits
    result = 0
    self.years.each do |year|
      result += year.count_credits
    end
    return result
  end

  def credits_percentages
    result = {min: 0, max: 0, overflow: 0}
    # percentage = (self.count_credits.to_f / self.program.min.to_f)
    if self.count_credits <= self.program.min
      result[:min] = StudentProgram.percentage(self.count_credits, self.program.min )
    elsif self.count_credits > self.program.min and self.count_credits <= self.program.max
      result[:min] = 50
      result[:max] = StudentProgram.percentage(self.count_credits-self.program.min, self.program.max - self.program.min)/2
    else
      result[:min] = 40
      result[:max] = 40
      result[:overflow] = StudentProgram.percentage(self.count_credits-self.program.max, self.program.min+self.program.max)*0.2
    end
    return result
  end





  def can_validates?
    self.checked? and ! self.justification.has_uncompleted_exceptions? and self.validation.nil?
    # (self.errors_count == 0 or ! self.justification.nil?) and (self.enough_credits?) and (self.validation.nil?)
  end

  def enough_credits?
    (self.count_credits >= self.program.min and self.count_credits <= self.program.max) or (self.count_credits >= self.program.count_credits)
  end


  def set_count(count)
    self.errors_count = count
    self.save
  end

  def first_semester_available_courses
    courses = self.program.first_semester_courses
    self.years.each do |year|
      if year.status.eql? "0"
        courses -= year.first_semester.courses
        courses -= year.second_semester.courses
      else
        courses -= year.first_semester.coresponding_courses(self.program)
        courses -= year.second_semester.coresponding_courses(self.program)
      end
    end
    return courses
  end

  def second_semester_available_courses
    courses = self.program.second_semester_courses
    self.years.each do |year|
      if year.status.eql? "0"
        courses -= year.first_semester.courses
        courses -= year.second_semester.courses
      else
        courses -= year.first_semester.coresponding_courses(self.program)
        courses -= year.second_semester.coresponding_courses(self.program)
      end
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
    ! self.validation.nil?
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
private
  
  def create_constraint_exceptions(results)
    results.each do |result|
      p result.class
      case result.class.name
        when "ConstraintsChecker::Constraints::Prerequisite"
          entity = Constraint.find(result.id)
          type = "Prerequisite"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::Corequisite"
          entity = Constraint.find(result.id)
          type = "Corequisite"
          self.justification.constraint_exceptions.create(entity:entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::OrPrerequisite"
          entity = Constraint.find(result.id)
          type = "OrPrerequisite"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::XorPrerequisite"
          entity = Constraint.find(result.id)
          type = "XorPrerequisite"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::OrCorequisite"
          entity = Constraint.find(result.id)
          type = "OrCorequisite"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::XorCorequisite"
          entity = Constraint.find(result.id)
          type = "XorCorequisite"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::Mandatory"
          entity = PModule.find(result.target.id)
          type = "Mandatory"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::MandatoryCourse"
          entity = Course.find(result.course_id)
          type = "Mandatory"
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::Min"
          type = "Min"
          if result.target.class.name.eql? "ConstraintsChecker::Catalog"
            entity = self.program
          else
            entity = PModule.find(result.target.id)
          end
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
        when "ConstraintsChecker::Constraints::Max"
          type = "Max"
          if result.target.class.name.eql? "ConstraintsChecker::Catalog"
            entity = self.program
          else
            entity = PModule.find(result.target.id)
          end
          self.justification.constraint_exceptions.create(entity: entity, constraint_type: type)
      end
    end

  end


  def self.percentage(value1, value2)
    result = (value1.to_f / value2.to_f) * 100
    if result > 100
      result = 100
    end
    return result
  end
end
