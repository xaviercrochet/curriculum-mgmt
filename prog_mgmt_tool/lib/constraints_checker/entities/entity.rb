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
				p "number of contraints for <"+id.to_s+">:" + constraints.size.to_s
				if constraints.size > 0
					logs = []
					constraints.each do |c|
						 logs << c.check
					end
					p logs.to_s
					if logs.size == 0 
						true
					else
						logs
					end
				else
					true
				end
			end

		end

		class Course < Entity
			attr_accessor :sub_module
			attr_accessor :p_module
			attr_accessor :passed
			attr_accessor :credits

			def initialize(id, name, credits, catalog, sub_module, p_module)
				super(id, name, catalog) 
				self.p_module = p_module
				self.sub_module = sub_module
				self.passed = true
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
				self.courses = {}
				self.p_modules = []
				self.sub_modules = []
			end

			def add_course(course)
				p "Adding course ..."
				self.courses[course.id] = course
			end

			def search_course(id)
				p "seach course <"+id.to_s+">"
				if courses[id].nil?
					p "COUCOU"
				end
				courses[id]
			end

			def check
				logs = []
				p "#of courses : "+courses.size.to_s
				courses.each do |key, value|
					if ! value.nil?
						logs << value.check 
					end
				end
				logs.flatten!
			end
		end
	end
end