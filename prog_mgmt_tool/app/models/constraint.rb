class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :course
  has_and_belongs_to_many :courses
  scope :in, -> {where(:role => 'IN')}
  scope :out, -> {where(:role => 'OUT')}

  before_save {
  	self.set_type = set_type.upcase
  }


  def self.create_constraint(catalog, set_type, type, source, destination)
		 
		constraint = destination.constraints.create()
		constraint.constraint_type = type
		constraint.courses << source
		constraint.set_type = set_type
		constraint.save
	end

	def self.create_binary_constraint(edge, courses, catalog)
		type = ConstraintType.create_type(edge.get_type.to_s, catalog)
		source = Course.where(:catalog_id => catalog.id, :id => courses[edge.get_source.get_id]["real_id"].to_i).first
		destination = Course.where(:catalog_id => catalog.id, :id => courses[edge.get_destination.get_id]["real_id"].to_i).first
		Constraint.create_constraint(catalog, "BINARY", type, source, destination)
	end

	def self.create_n_ary_constraint(node, edges, courses, catalog)
		set_type = node.get_name.to_s
		type = ConstraintType.create_type(edges.first.get_type.to_s, catalog) 
		edges_dst = node.get_outcoming_edges(edges)
		destinations = []
		edges_dst.each do |edge|
			destinations << Course.find(courses[edge.get_destination.get_id.to_i]["real_id"])
		end

		edges_src = node.get_incoming_edges(edges)
		sources = []
		edges_src.each do |edge|
			sources << Course.find(courses[edge.get_source.get_id.to_i]["real_id"])
		end

		destinations.each do |course_dst|
			sources.each do |course_src|
				Constraint.create_constraint(catalog, set_type, type, course_src, course_dst)
			end
		end
	end

	def is_binary_corequisite?
		self.role.eql? 'IN' and self.constraint_type.name.eql? 'COREQUISITE' and self.constraint_set.constraint_set_type.name = 'BINARY'
	end

	def to_object(target_object)
		if self.constraint_type.name.eql? "PREREQUISITE"
			ConstraintsChecker::Constraints::Prerequisite.new(self.entity.id, target_object)
		elsif self.constraint_type.name.eql? "COREQUISITE"
			ConstraintsChecker::Constraints::Corequisite.new(self.entity.id, target_object)
		end
	end

	def pairs
		if self.role.eql? 'OUT'
			self.constraint_set.constraints.in
		elsif self.is_binary_corequisite?
			self.constraint_set.constraints.out
		else
			Constraint.none
		end
	end

end
