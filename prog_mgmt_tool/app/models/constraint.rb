class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :course
  has_and_belongs_to_many :courses
  default_scope includes(:constraint_type)
  scope :in, -> {where(:role => 'IN')}
  scope :out, -> {where(:role => 'OUT')}

  scope :prerequisites, -> {where(constraint_types: {name: "PREREQUISITE"})}
  scope :corequisites, -> {where(constraint_types: {name: "COREQUISITE"})}
  scope :binary, -> {where(set_type: "BINARY")}
  scope :xor, -> {where(set_type: "X")}
  scope :o_r, -> {where(set_type: "OR")}

  before_save {
  	self.set_type = set_type.upcase
  }


  def self.create_constraint(set_type, type, source, destination)
		 
		constraint = destination.constraints.create()
		constraint.constraint_type = type
		constraint.courses << source
		constraint.set_type = set_type
		constraint.save
	end

	def self.create_binary_constraint(source, destination, type)
    type = ConstraintType.create_type(type, source.catalog)
		Constraint.create_constraint("BINARY", type, source, destination)
	end

	def self.create_n_ary_constraint(sources, destinations, set_type, type)
		type = ConstraintType.create_type(type, sources.first.catalog) 

		destinations.each do |course_dst|
			sources.each do |course_src|
				Constraint.create_constraint(set_type, type, course_src, course_dst)
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
