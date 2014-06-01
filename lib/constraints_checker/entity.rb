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

		#look for an entity using his id and his class name
		#the trick to first look for the root of the tree
		#then call the find_children method on the root
		def search(children_id, children_type)
			root = find_root
			root.find_children(children_id, children_type)
		end

		#look for an entity using his id and his class name

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
			unverified_constraints = []
			@constraints.each do |c|
				if c.check != true
					unverified_constraints << c
				end
			end
			unverified_constraints << check_childrens_constraints
			return unverified_constraints.flatten
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
			unverified_constraints = []
			self.childrens.each do |children|
				# if children.constraints.size > 0
				# 	logs << children.check
				# end
				unverified_constraints << children.check
			end
			return unverified_constraints
		end
	end	
end