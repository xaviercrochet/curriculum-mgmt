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
				course = target.catalog.search_course(source)
				if course.nil?
					{not_present: source}
				else
					{not_passed: source}
				end
				true
			end
		end

		class Corequisite < BinaryConstraint
			def initialize(source, target)
				super(source, target)
			end

			def check
				! target.catalog.search_course(source.id)
			end
		end
	end
end