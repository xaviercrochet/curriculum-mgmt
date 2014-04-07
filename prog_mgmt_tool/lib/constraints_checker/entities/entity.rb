module ConstraintsChecker
	module Entities
		class Entity
			attr_accessor :name
			attr_accessor :catalog
			attr_accessor :constraints
			attr_accessor :id

			def initialize(id, name, catalog)
				self.id = id
				self.name = name
				self.catalog = catalog
				self.constraints = []
			end

			def add_constraint(constraint)
				self.constraints << constraint
			end

			def check
				constraints.each do |c|
					if ! c.check
						return false
					end
				end
				true
			end

		end

		class Course < Entity
			attr_accessor :sub_module
			attr_accessor :p_module
			attr_accessor :passed
			attr_accessor :credits

			def initialize(id, name, catalog, sub_module, p_module)
				super(id, name, catalog) 
				self.p_module = p_module
				self.sub_module = sub_module
				self.passed = false
			end

		end

		class PModule < Entity
			attr_accessor :sub_modules
			attr_accessor :courses

			def initialize(id, name, catalog, courses, sub_modules)
				super(id, name, catalog) 
				self.courses = courses
				self.sub_modules = sub_modules
			end

		end

		class SubModule < Entity
			attr_accessor :p_module
			attr_accessor :courses
			attr_accessor :min_credits
			attr_accessor :max_credits

			def initialize(id, name, catalog, courses, p_module)
				super(id, name, catalog) 
				self.courses = courses 
				self.p_module = p_module
			end

		end

		class Catalog
			attr_accessor :courses
			attr_accessor :p_modules
			attr_accessor :sub_modules

			def initialize()
				self.courses = []
				self.p_modules = []
				self.sub_modules = []
			end

			def add_course(course)
				self.courses.insert(course.id, course)
			end

			def search_course(id)
				courses.at(id)
			end

			def check
				courses.each do |course|
					if ! course.check
						return false
					end
				end
				true
			end
		end
	end
end