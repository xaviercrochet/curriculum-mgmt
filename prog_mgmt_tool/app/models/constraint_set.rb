class ConstraintSet < ActiveRecord::Base
	has_many :constraints, dependent: :destroy
	belongs_to :constraint_set_type

	def self.create_sets(edges, courses, nodes, catalog)
		nodes.each do |node|
			if node.get_is_constraint?
				ConstraintSet.create_set(node, edges, courses, catalog)
			end
		end
	end
	
	def self.create_binary_constraint(edge, courses, catalog)
		source = Course.where(:catalog_id => catalog.id, :id => courses[edge.get_source.get_id]["real_id"].to_i).first
		destination = Course.where(:catalog_id => catalog.id, :id => courses[edge.get_destination.get_id]["real_id"].to_i).first
		set_type = ConstraintSetType.create_type("BINARY", catalog)
		set = set_type.constraint_sets.create
		Constraint.create_constraint(source, set, edge, "IN", catalog)
		Constraint.create_constraint(destination, set, edge, "OUT", catalog)
	end 

	def self.create_unary_constraint_on_properties(entity, type, value)
		set_type = ConstraintSetType.create_type("UNARY", entity.catalog)
		p "SET TYPE: " + set_type.to_s
		set = set_type.constraint_sets.create
		constraint_type = ConstraintType.create_type(type, entity.catalog)
		constraint = entity.constraints.new
		constraint.constraint_type = constraint_type
		constraint.constraint_set = set
		constraint.save
	end

	
	private

	def self.create_set(node, edges, courses, catalog)
		type = ConstraintSetType.create_type(node.get_name.to_s, catalog)
		set = type.constraint_sets.create
		ConstraintSet.add_sources(node, set, edges, courses, catalog)
		ConstraintSet.add_destinations(node, set,  edges, courses, catalog)
		set.save
	end
	
	def self.add_sources(node, set, edges, courses, catalog)
		edges_list = node.get_incoming_edges(edges)
		edges_list.each do |edge|
			course = Course.find(courses[edge.get_source.get_id.to_i]["real_id"])
			Constraint.create_constraint(course, set, edge, "IN", catalog)
		end
	end

	def self.add_destinations(node, set, edges, courses, catalog)
		edges_list = node.get_outcoming_edges(edges)
		edges_list.each do |edge|
			course = Course.find(courses[edge.get_destination.get_id.to_i]["real_id"])
			Constraint.create_constraint(course, set, edge, "OUT", catalog)
		end
	end
end
