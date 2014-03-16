class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :constraint_set
  belongs_to :course

  before_save {
  	self.role = role.upcase
  }

  def self.create_constraint(course, set, edge, role)
		type = ConstraintType.create_type(edge.get_type)
		constraint = course.constraints.create(:role => role.to_s)
		constraint.constraint_type = type
		constraint.constraint_set = set 
		constraint.save
		constraint
	end

end
