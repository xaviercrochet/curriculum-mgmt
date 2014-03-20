class Property < ActiveRecord::Base
	belongs_to :entity, :polymorphic => true
	validates :email, presence: true
	validates :faculty, presence: true
	
	before_save {
		self.p_type = p_type.upcase
		self.value = value.upcase
	}
	scope :main, -> {where(:primary => true).first}
end
