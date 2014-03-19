class PModule < ActiveRecord::Base
  belongs_to :program
  belongs_to :catalog
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :courses, as: :block, dependent: :destroy
  has_many :sub_modules, dependent: :destroy


	def self.find_by_property(property_type, property_value, catalog)
		catalog.p_modules.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value).first
	end

	def update_properties(properties)
		self.properties.each do |p|
			p.destroy
		end

		properties.each do |key, value|
			self.properties.create(:p_type => key.to_s, :value => value.to_s)
		end
	end

	def has_sub_modules?
		self.sub_modules.count > 0
	end

	def has_courses?
		self.courses.count > 0
	end

	def as_json(option={})
		if self.has_sub_modules? and self.has_courses?
			{
				:name => self.properties.main.value,
				:sub_modules => self.sub_modules.as_json,
				:courses => self.courses.as_json
			}
		elsif self.has_sub_modules? and ! self.has_courses?
			{
				:name => self.properties.main.value,
				:sub_modules => self.sub_modules.as_json
			}
		elsif ! self.has_sub_modules? and self.has_courses?
			{
				:name => self.properties.main.value,
				:courses => self.courses.as_json
			}
		end

	end
end
