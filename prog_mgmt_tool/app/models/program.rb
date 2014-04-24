class Program < ActiveRecord::Base
	has_many :p_modules, dependent: :destroy
	has_many :properties, as: :entity, dependent: :destroy
	has_many :courses, as: :block, dependent: :destroy
	belongs_to :catalog

	def self.find_by_property(property_type, property_value, catalog)
		catalog.programs.includes(:properties).where('property.p_type' => propertyy_type, 'property.p_value' => property_value).first
	end

	def update_properties(properties)
		properties.each do |key, value|
			p = self.properties.where(:p_type => key.to_s).first
			
			if p.nil?
				self.properties.create(:p_type => key.to_s, :value => value.to_s)
			
			else
				p.value = value.to_s
				p.save
			end
		end
	end

	def name
		p = self.properties.where(:p_type => 'NAME').first
		if p.nil?
			self.properties.first.value
		else
			p.value
		end
	end

	def has_modules?
		self.p_modules.count > 0
	end

	def has_courses?
		self.courses.count > 0
	end

	def self.find_by_property(property_type, property_value, catalog)
		catalog.programs.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value).first
	end

	def as_json(option={})
		if self.has_modules? and self.has_courses?
			{
				:name => self.properties.main.value,
				:children => self.p_modules.as_json,
				:children => self.courses.as_json			
			}
		elsif self.has_modules? and ! self.has_courses?
			{
				:name => self.properties.main.value,
				:children => self.p_modules.as_json
			}
		elsif !self.has_modules? and self.has_courses?
			{
				:name => self.properties.main.value,
				:children => self.courses.as_json
			}
		end
			
	end

	def self.constraints_header
		["NAME", "MIN", "MAX"]
	end
 	
 	def properties_to_hash
    props = Hash.new
    self.properties.each do |p|
      props[p.p_type.to_s] = p.value.to_s
    end
    props
  end

end
