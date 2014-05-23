class Property < ActiveRecord::Base
	belongs_to :entity, :polymorphic => true
	
  validates :p_type, presence: true
  validates :value, presence: true

  scope :first_semester, -> {where(p_type: "SEMESTRE", value: "1")}
  scope :second_semester, -> {where(p_type: "SEMESTRE", value: "2")}
  scope :both_semesters, -> {where(p_type: "SEMESTRE", value: "NONE")}
  scope :mandatory, -> {where(p_type: "OBLIGATOIRE", value: "OUI")}
  scope :optional, -> {where(p_type: "OBLIGATOIRE", value: "NON")}
  scope :credits, -> {where p_type: "CREDITS"}

	before_save {
		self.p_type = p_type.upcase
		self.value = value.upcase
	}
	scope :main, -> {where(:primary => true).first}
end
