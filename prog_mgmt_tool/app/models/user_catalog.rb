require 'constraints_checker/constraints/constraint'
require 'constraints_checker/entities/entity'

class UserCatalog < ActiveRecord::Base
	attr_accessor :catalog_object

	has_and_belongs_to_many :courses
	belongs_to :user

	
	def check
		catalog.check
	end

	def to_object
		self.catalog_object = ConstraintsChecker::Entities::Catalog.new
		self.courses.each do |course|
			catalog.add_course(course.to_object(self.catalog_object, nil, nil))
		end
	end
end
