class ConstraintException < ActiveRecord::Base
  belongs_to :justification
  belongs_to :entity, polymorphic: true

  scope :prerequisite, ->{where(constraint_type: "Prerequisite")}
  scope :corequisite, -> {where(constraint_type: "Corequisite")}
  scope :or_prerequisite, -> {where(constraint_type: "OrPrerequisite")}
  scope :or_corequisite, -> {where(constraint_type: "OrCorequisite")}
  scope :xor_prerequisite, -> {where(constraint_type: "XorPrerequisite")}
  scope :xor_corequisite, -> {where(constraint_type: "XorCorequisite")}
  scope :min, -> {where(constraint_type: "Min")}
  scope :max, ->{where(constraint_type: "Max")}
  scope :mandatory, -> {where(constraint_type: "Mandatory")}
  scope :un_completed, -> {where(completed: false)}

  def complete
    self.completed = true
    self.save
  end

  def uncomplete
    self.completed = false
    self.save
  end

  def completed?
    self.completed
  end

end
