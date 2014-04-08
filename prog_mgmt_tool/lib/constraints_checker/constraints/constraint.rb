module ConstraintsChecker
	module Constraints
		class Constraint
		end

		class PropertyConstraint < Constraint
			attr_accessor :target
			attr_accessor :property 
			attr_accessor :value

			def initialize(target, property, value)
				self.property = property
				self.target = target
				self.value = value
			end

			def check
				if ! target.property.nil?
					if ! target.property.eql? value
						{self.property.to_s => value.to_s}
					end
				else
					{self.property.to_s => 'not present'}
				end
				false
			end
		end

		class BinaryConstraint < Constraint
			
			attr_accessor :source
			attr_accessor :target

			def initialize(source, target)
				self.source = source
				self.target = target
			end
		end

		class Prerequisite < BinaryConstraint
			
			def initialize(source, target)
				super(source, target)
			end

			def check
				p "Prerequisite check"
				course = target.catalog.search_course(self.source)
				p "Course Name : "+course.name.to_s
				if course.nil?
					p "Course not present!"
					{not_present: self.source}
				elsif ! course.passed
					p "Course present but not passed!"
					{not_passed: self.source}
				else
					p "Prerequisite check passed!"
					true
				end
			end
		end

		class Corequisite < BinaryConstraint
			def initialize(source, target)
				super(source, target)
			end

			def check
				p "Corequisite check"
				course = target.catalog.search_course(self.source)
				if course.nil?
					p "Course not present!"
					{not_present: self.source}
				else
					p "Corequisite check passed!"
					true
				end
			end
		end
	end
end