
class PModule < ActiveRecord::Base
  belongs_to :catalog
  has_and_belongs_to_many :programs
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :courses, dependent: :destroy
  has_many :sub_modules, class_name: "PModule", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "PModule"

	def self.find_by_property(property_type, property_value, catalog)
		catalog.p_modules.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value).first
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

	def find_property(p_type)
		self.includes(:properties).where('properties.p_type' => p_type).first
	end

	def contraints(p_module_object)
		constraints = []
		min = self.find_property('MIN')
		if ! min.nil?
			constraints << ConstraintChecker::Constraints::Min.new(p_module_object, min.value)
		end
		max = self.find_property('MAX')
		if !max.nil?
			constraints << ConstraintChecker::Constraints::Max.new(p_module_object, max.value)
		end
		constraints 

	end


	def to_object(catalog_object)
		self.p_module_object = ConstraintsChecker::Entities::PModule.new(self.id, self.name, catalog_object)
		contraints = self.constraints(self.p_module_object)
		constraints.each do |c|
			self.p_module_object.add_constraint(c)
		end
		self.p_module_object
	end

	def name
		p = self.properties.where(:p_type => 'NAME').first
		if p.nil?
			self.properties.first.value
		else
			p.value
		end
	end

	def has_sub_modules?
		self.sub_modules.count > 0
	end

	def has_courses?
		self.courses.count > 0
	end

	def self.constraints_header
		["NAME", "MIN", "MAX"]
	end

	def self.find_by_property(property_type, property_value, catalog)
    catalog.p_modules.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value.to_s).first
  end

	def as_json(option={})
		if self.has_sub_modules? and self.has_courses?
			childrens = self.courses.as_json + self.sub_modules.as_json
			{
				:name => self.properties.main.value,
				:children => childrens 
				
			}
		elsif self.has_sub_modules? and ! self.has_courses?
			{
				:name => self.properties.main.value,
				:children => self.sub_modules.as_json
			}
		elsif ! self.has_sub_modules? and self.has_courses?
			{
				:name => self.properties.main.value,
				:children => self.courses.as_json
			}
		end

	end

	def properties_to_hash
    props = Hash.new
    self.properties.each do |p|
      props[p.p_type.to_s] = p.value.to_s
    end
    props
  end
end
