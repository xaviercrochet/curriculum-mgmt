require 'constraints_checker/catalog'

class StudentProgram < ActiveRecord::Base
  belongs_to :program
  has_many :years, dependent: :destroy

  def check_constraints
    c = ConstraintsChecker::Catalog.new
    self.years.each do |year|
      year.get_course_objects.each do |course|
        c.add_course(course)
      end
    end
    return c.check
  end
end
