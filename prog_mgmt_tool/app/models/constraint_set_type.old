class ConstraintSetType < ActiveRecord::Base
		has_many :constraint_sets, dependent: :destroy
		belongs_to :catalog

		before_save {
		self.name = name.upcase
	}

	def self.create_type(type, catalog)
		c_set_type = ConstraintSetType.where(:name => type).first
		if c_set_type.nil?
			c_set_type = catalog.constraint_set_types.create(:name => type)
		end
		c_set_type
		end
end
