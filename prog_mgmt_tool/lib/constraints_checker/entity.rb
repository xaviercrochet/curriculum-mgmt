require 'ostruct'
module ConstraintsChecker
	class Entity < OpenStruct
		attr_accessor :parent
		attr_accessor :childrens
		attr_accessor :constraints

		def add_constraint(constraint)
			@constraints ||= []
			@constraints << constraint
		end

		def add_children(children)
			@childrens ||= []
			@childrens << children
		end

		def count_credits
			credits = 0
			childrens.each do |children|
				credits = credits + children.count_credits
			end
			return credits
		end

		def check
			p "number of contraints for <"+id.to_s+">:" + @constraints.size.to_s
			logs = []
			@constraints.each do |c|
					 logs << c.check
			end
			return logs				
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