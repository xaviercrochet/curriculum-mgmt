require 'constraints_checker/catalog'

class StudentProgram < ActiveRecord::Base
  belongs_to :program
  has_many :years, dependent: :destroy
  has_many :validations, dependent: :destroy

  def check_constraints
    c = ConstraintsChecker::Catalog.new
    self.years.each do |year|
      year.get_course_objects.each do |course|
        c.add_course(course)
      end
    end
    return c.check
  end

  def validation_request_already_sent
    self.validations.count > 0
  end

  def validate
    self.validated = true
  end
end
