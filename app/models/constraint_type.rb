class ConstraintType < ActiveRecord::Base
	has_many :constraints, dependent: :destroy
	belongs_to :catalog
	before_save {
		self.name = name.upcase
	}

	scope :prerequisites, -> {where(name: "PREREQUISITE")}
	scope :corequisites, -> {where(name: "COREQUISITE")}

		def self.create_type(type, catalog)
		c_type = catalog.constraint_types.where(name: type).first
		if c_type.nil?
			c_type = catalog.constraint_types.create(name: type)
		end
		c_type
	end
end
