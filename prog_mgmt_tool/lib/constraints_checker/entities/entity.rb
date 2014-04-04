module ConstraintsChecker
	module Entities
		class Entity
			attr_accessor :name

			def initialize(name)
				self.name = name
			end

			def check
			end

		end

		class Course < Entity
			attr_accessor :sub_module
			attr_accessor :p_module

			def initialize(name, sub_module, p_module)
				super name
				self.p_module = p_module
				self.sub_module = sub_module
			end

			def check
			end
		end

		class PModule < Entity
			attr_accessor :sub_modules
			attr_accessor :courses

			def initialize(name, courses, sub_modules)
				super name
				self.courses = courses
				self.sub_modules = sub_modules
			end

			def check
			end
		end

		class SubModule < Entity
			attr_accessor :p_module
			attr_accessor :courses

			def initialize(name, courses, p_module)
				super name
				self.courses = courses 
				self.p_module = p_module
			end

			def check
			end
		end
	end
end