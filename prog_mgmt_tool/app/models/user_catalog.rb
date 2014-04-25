
class UserCatalog < ActiveRecord::Base
	attr_accessor :catalog_object

	has_and_belongs_to_many :courses
	has_and_belongs_to_many :p_modules
	has_and_belongs_to_many :programs
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
		self.p_modules.each do |p_module|
			self.catalog_object.add_p_module(p_module.to_object(self.catalog_object))
		end
		self.courses.each do |course|
			add_course_to_object(course, self.catalog_object)
		end
		p self.catalog_object.check
		

		p "finished building catalog object."
	end

private
	def add_course_to_object(course, catalog_object)
		
		if course.block_type.eql? 'PModule'
			p_module = catalog_object.find_p_module(course.block_id)
			if ! p_module.nil?
				p_module.add_course(course.to_object(catalog_object))
				course.set_parent(p_module)
			end
		else
			catalog_object.add_course(course.to_object(catalog_object))
		end
	end
end
