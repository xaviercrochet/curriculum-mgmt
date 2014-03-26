class SubModule < ActiveRecord::Base
  belongs_to :p_module
  belongs_to :catalog
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :courses, as: :block, dependent: :destroy

	def self.find_by_property(property_type, property_value, catalog)
		catalog.sub_modules.includes(:properties).where('property.p_type' => property_type, 'property.value' => property_value).first
	end

	def name
		p = self.properties.where(:p_type => 'NAME').first
		if p.nil?
			self.properties.first.value
		else
			p.value
		end
	end

	def update_properties(properties)
		self.properties.each do |p|
			p.destroy
		end

		properties.each do |key, value|
			self.properties.create(:p_type => key.to_s, :value => value.to_s)
		end
	end

	def has_courses?
		self.courses.count > 0
	end

	def as_json(option={})
		if self.has_courses?
			{
				:name => self.properties.main.value,
				:children => self.courses.as_json
			}
		else
			{
				:name => self.properties.main.value
			}
		end
	end
	def self.constraints_header
		["NAME", "MIN", "MAX", "CREDITS"]
	end

	def properties_to_hash
    props = Hash.new
    self.properties.each do |p|
      props[p.p_type.to_s] = p.value.to_s
    end
    props
  end


end
