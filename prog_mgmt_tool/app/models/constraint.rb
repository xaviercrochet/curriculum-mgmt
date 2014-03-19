class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :constraint_set
  belongs_to :course
  scope :in, -> {where(:role => 'IN')}
  scope :out, -> {where(:role => 'OUT')}

  before_save {
  	self.role = role.upcase
  }

  def self.create_constraint(course, set, edge, role, catalog)
		type = ConstraintType.create_type(edge.get_type, catalog)
		constraint = course.constraints.create(:role => role.to_s)
		constraint.constraint_type = type
		constraint.constraint_set = set 
		constraint.save
		constraint
	end

	def pairs
		if self.role.eql? 'OUT'
			self.constraint_set.constraints.in
		end
	end

end
