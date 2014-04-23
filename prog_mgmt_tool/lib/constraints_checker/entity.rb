require 'ostruct'
module ConstraintsChecker
	class Entity < OpenStruct
		attr_accessor :parent
		attr_accessor :childrens
		attr_accessor :constraints

		def initialize(properties)
			super(properties)
			self.constraints = []
			self.childrens = []
		end

		def add_constraint(constraint)
			self.constraints << constraint
		end

		def add_constraints(constraints)
			constraints.each do |c|
				@constraints << c
			end
		end

		def add_children(children)
			@childrens << children
			children.parent = self
		end

		def add_childrens(childrens)
			childrens.each do |c|
				@childrens << c
				c.parent = self
			end
		end

		def search(children_id, children_type)
			root = find_root
			root.find_children(children_id, children_type)
		end

		def find_children(children_id, children_type)
			result
			if self.id.eql? children_id and self.class.name.eql? children_type
				result = self
			else
				@childrens.each do |c|
					result = c.find_children(children_id, children_type)
					break if result
				end
			end
			return result
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

		def find_root
			if @parent.nil?
				return self
			else
				return @parent.find_root
			end
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