require 'constraints_checker/catalog'

class StudentProgram < ActiveRecord::Base
  belongs_to :program
  has_many :years, dependent: :destroy
  has_many :validations, dependent: :destroy
  has_and_belongs_to_many :p_modules

  def check_constraints
    c = ConstraintsChecker::Catalog.new(id: self.id)
    self.years.each do |year|
      year.get_course_objects.each do |course|
        c.add_course(course)
      end
    end
    return c.check
  end

  def is_p_module_present?(p_module)
    self.p_modules.where(id: p_module.id).count > 0
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
