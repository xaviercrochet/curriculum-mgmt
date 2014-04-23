require 'ostruct'
module ConstraintsChecker
	class Entity < OpenStruct
		attr_accessor :parent
		attr_accessor :childrens
		attr_accessor :constraints

		def add_constraint(constraint)
			self.constraints ||= []
			self.constraints << constraint
		end

		def add_constraints(constraints)
			@constraints ||= []
			constraints.each do |c|
				@constraints << c
			end
		end

		def add_children(children)
			@childrens ||= []
			@childrens << children
		end

		def add_childrens(childrens)
			@childrens ||= []
			childrens.each do |c|
				@childrens << c
			end
		end

		def count_credits
			credits = 0
			childrens.each do |children|
				credits = credits + children.count_credits
			end
			return credits
		end

		def check
			logs = []
			@constraints.each do |c|
				if c.check != true
				 	logs << c.check
				 end
			end
			return logs				
		end

		def check_max(value)
			return count_credits <= value.to_i
		end

		def check_min(value)
			return count_credits >= value.to_i
		end

	private
		
		def check_childrens_constraints
			logs = []
			@childrens.each do |children|
				if children.constraints.size > 0
					logs << children.check
				end
			end
			return logs
		end
	end	
end