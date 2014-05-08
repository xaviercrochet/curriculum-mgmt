class Property < ActiveRecord::Base
	belongs_to :entity, :polymorphic => true
	
  validates :p_type, presence: true
  validates :value, presence: true

  scope :semester, -> {where p_type: "SEMESTRE"}
  scope :mandatory, -> {where p_type: "OBLIGATOIRE"}
  scope :credits, -> {where p_type: "CREDITS"}

	before_save {
		self.p_type = p_type.upcase
		self.value = value.upcase
	}
	scope :main, -> {where(:primary => true).first}
end
