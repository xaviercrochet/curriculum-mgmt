require 'constraints_checker/constraints/constraint'
require 'constraints_checker/entities/entity'

class UserCatalog < ActiveRecord::Base
	attr_accessor :catalog_object

	has_and_belongs_to_many :courses
	belongs_to :user

	
	def check
		self.catalog_object.check
	end

	def object
		self.catalog_object
	end

	def to_object
		self.catalog_object = ConstraintsChecker::Entities::Catalog.new
		p "building catalog object ..."	
		self.courses.each do |course|
			self.catalog_object.add_course(course.to_object(self.catalog_object, nil, nil))
		end
		p self.catalog_object.check
		

		p "finished building catalog object."
	end
end
