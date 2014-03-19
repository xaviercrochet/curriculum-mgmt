class Property < ActiveRecord::Base
	belongs_to :entity, :polymorphic => true
	before_save {
		self.p_type = p_type.upcase
		self.value = value.upcase
	}
	scope :main, -> {where(:primary => true)}
end
