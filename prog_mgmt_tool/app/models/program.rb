class Program < ActiveRecord::Base
	has_many :p_modules, dependent: :destroy
	has_many :properties, as: :entity, dependent: :destroy
	has_many :courses, as: :block, dependent: :destroy
	belongs_to :catalog

	def self.find_by_property(property_type, property_value, catalog)
		catalog.programs.includes(:properties).where('property.p_type' => propertyy_type, 'property.p_value' => property_value).first
	end

	def update_properties(properties)
		self.properties.each do |p|
			p.destroy
		end

		properties.each do |key, value|
			self.properties.create(:p_type => key, :value => value)
		end
	end


end
