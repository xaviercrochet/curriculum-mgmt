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
			attr_accessor :parent
			attr_accessor :passed
			attr_accessor :credits

			def initialize(id, name, credits, catalog, parent)
				super(id, name, catalog) 
				self.parent = parent
				self.passed = true
			end

		end

		class PModule < Entity
			attr_accessor :sub_modules
			attr_accessor :courses

			def initialize(id, name, catalog)
				super(id, name, catalog)
			end

			def add_course(course)
				courses[course.id] = course
			end

			def find_course(course_id)
				p "searching course <"+course_id.to_s+">"
				if courses[course_id].nil?
					p "Course not found :-/"
				end
				courses[course_id]
			end

			def count_credits
				credits = 0
				self.sub_modues.each do |m|
					credits = credits + m.count_credits.to_i
				end
				self.courses.each do |c|
					credits = credits + c.credits.to_i unless c.credits.eql? 'NONE'
				end
				credits
			end

			def check_min(value)
				self.count_credits >= value
			end

			def check_max(value)
				self.count_credits <= value
			end

		end

		class SubModule < Entity
			attr_accessor :p_module
			attr_accessor :courses

			def initialize(id, name, catalog, courses, p_module)
				super(id, name, catalog) 
				self.courses = courses 
				self.p_module = p_module
			end

			def count_credits
				credits = 0
				self.courses.each do |c|
					credits = credits + c.credits.to_i unless c.credits.eql? 'NONE'
				end
				credits
			end

			def check_min(value)
				count_credits >= value
			end

			def check_max(value)
				count_credits <= value
			end
		end

		class Catalog
			attr_accessor :courses
			attr_accessor :p_modules
			attr_accessor :sub_modules

			def initialize()
				self.courses = {}
				self.p_modules = {}
				self.sub_modules = {}
			end

			def find_p_module(id)
				p "searching course <"+id.to_s+">"
				if self.p_modules[id].nil?
					p "PModule not found :-/"
				end
				self.p_modules[id]
			end

			def add_course(course)
				p "Adding course ..."
				self.courses[course.id] = course
			end

			def add_p_module(p_module_id)
				self.p_modules[p_module_id]
			end

			def find_course(id)
				p "seach course <"+id.to_s+">"
				if self.courses[id].nil?
					p "Course not found :-/"
				end
				self.courses[id]
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