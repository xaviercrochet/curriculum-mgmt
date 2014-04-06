module ConstraintsChecker
	module Constraints
		class Constraint
			def check
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
				course = target.catalog.search_course(source.id)
				if course.nil?
					false
				else
					course.passed?
				end
			end
		end

		class Corequisite < BinaryConstraint
			def initialize(source, target)
				super(source, target)
			end

			def check
				! target.catalog.courses[source.id].nil?
			end
		end
	end
end