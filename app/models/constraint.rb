require 'constraints_checker/constraints/binary_constraint'
require 'constraints_checker/constraints/constraint_set'

class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :course
  has_and_belongs_to_many :courses

  scope :prerequisites, -> {includes(:constraint_type).merge(ConstraintType.prerequisites).references(:constraint_type)}
  scope :corequisites, -> {includes(:constraint_type).merge(ConstraintType.corequisites).references(:constraint_type)}
  scope :binary, -> {where(set_type: "BINARY")}
  scope :xor, -> {where(set_type: "X")}
  scope :o_r, -> {where(set_type: "OR")}

  before_save {
  	self.set_type = set_type.upcase
  }


  def self.create_constraint(set_type, type, sources, destination)
		 
		constraint = destination.constraints.create()
		constraint.constraint_type = type
		constraint.courses << sources
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
		  Constraint.create_constraint(set_type, type, sources, course_dst)
		end
	end

  def corequisite?
    return self.constraint_type.name.eql? "COREQUISITE"
  end

  def prerequisite?
    return self.constraint_type.name.eql? "PREREQUISITE"
  end

  #parse constraints received from constrant module and insert the coresponding constraint object in the database
  def get_constraint_object(course)
    constraint = nil
    case self.set_type
    when "BINARY"
      if self.corequisite?
        constraint = ConstraintsChecker::Constraints::Corequisite.new(self.id, course, self.courses.first.id)
      elsif self.prerequisite?
        constraint = ConstraintsChecker::Constraints::Prerequisite.new(self.id, course, self.courses.first.id)
      end
    when "X"
      constraint = get_xor_constraint_set_object(course)
    when "OR"
      constraint = get_or_constraint_set_object(course)
    when  "XOR"
      constraint = get_xor_constraint_set_object(course)
    end
    return constraint
  end
private

  def get_target_ids
    p "Getting target ids"
    target_ids = []
    self.courses.each do |course|
      target_ids << course.id
    end
    p target_ids
    return target_ids
  end

  def get_or_constraint_set_object(course)
    constraint = nil
    target_ids = get_target_ids
    if self.corequisite?
      constraint = ConstraintsChecker::Constraints::OrCorequisite.new(self.id, course, target_ids)
    elsif self.prerequisite?
      constraint = ConstraintsChecker::Constraints::OrPrerequisite.new(self.id, course, target_ids)
    end
    return constraint
  end

  def get_xor_constraint_set_object(course)
    constraint = nil
    target_ids = get_target_ids
    if self.corequisite?
      constraint = ConstraintsChecker::Constraints::XorCorequisite.new(self.id, course, target_ids)
    elsif self.prerequisite?
      constraint = ConstraintsChecker::Constraints::XorPrerequisite.new(self.id, course, target_ids)
    end
    return constraint
  end

  def get_binary_constraint_object(course)
    constraint = nil
    if self.corequisite?
      constraint = ConstraintsChecker::Constraints::Corequisite.new(self.id, course, self.courses.first.id)
    elsif self.prerequisite?
      constraint = ConstraintsChecker::Constraints::Prerequisite.new(self.id, course, self.courses.first.id)
    end
    return constraint
  end

end
