class ConstraintSet < ActiveRecord::Base
	has_many :constraints, dependent: :destroy
	belongs_to :constraint_set_type

	def self.create_sets(edges, courses, nodes)
		nodes.each do |node|
			if node.get_is_constraint?
				ConstraintSet.create_set(node, edges, courses)
			end
		end
	end


	
	private

	def self.create_set(node, edges, courses)
		type = ConstraintSetType.create_type(node.get_name.to_s)
		set = type.constraint_sets.create
		ConstraintSet.add_sources(node, set, edges, courses)
		ConstraintSet.add_destinations(node, set,  edges, courses)
		set.save
	end
	
	def self.add_sources(node, set, edges, courses)
		edges_list = node.get_incoming_edges(edges)
		edges_list.each do |edge|
			course = Course.find(courses[edge.get_source.get_id.to_i]["real_id"])
			Constraint.create_constraint(course, set, edge, "IN")
		end
	end

	def self.add_destinations(node, set, edges, courses)
		edges_list = node.get_outcoming_edges(edges)
		edges_list.each do |edge|
			course = Course.find(courses[edge.get_destination.get_id.to_i]["real_id"])
			Constraint.create_constraint(course, set, edge, "OUT")
		end
	end
end
