require 'constraints_checker/constraints/binary_constraint'

class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :course
  has_and_belongs_to_many :courses
  default_scope includes(:constraint_type)

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

  def corequisite?
    return self.constraint_type.name.eql? "COREQUISITE"
  end

  def prerequisite?
    return self.constraint_type.name.eql? "PREREQUISITE"
  end

  def get_constraint_object(course)
    constraint = nil
    if self.courses.count == 1
      if self.corequisite?
        constraint = ConstraintsChecker::Constraints::Corequisite.new(course, self.courses.first.id)
      elsif self.prerequisite?
        constraint = ConstraintsChecker::Constraints::Prerequisite.new(course, self.courses.first.id)
      end
    end
    return constraint
  end

  def get_constraint_set_object(course)
    constraint_set = nil
    self.courses.each do |c|
    end
    return constraint_set
  end

	def to_object(target_object)
		if self.constraint_type.name.eql? "PREREQUISITE"
			ConstraintsChecker::Constraints::Prerequisite.new(self.entity.id, target_object)
		elsif self.constraint_type.name.eql? "COREQUISITE"
			ConstraintsChecker::Constraints::Corequisite.new(self.entity.id, target_object)
		end
	end	


end
