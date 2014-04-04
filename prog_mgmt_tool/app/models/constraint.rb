class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :constraint_set
  belongs_to :entity, :polymorphic => true
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

	

	def is_binary_corequisite?
		self.role.eql? 'IN' and self.constraint_type.name.eql? 'COREQUISITE' and self.constraint_set.constraint_set_type.name = 'BINARY'
	end


	def pairs
		if self.role.eql? 'OUT'
			self.constraint_set.constraints.in
		elsif self.is_binary_corequisite?
			self.constraint_set.constraints.out
		end
	end

end
