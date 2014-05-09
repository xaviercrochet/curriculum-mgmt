require 'constraints_checker/entities/p_module'
require 'constraints_checker/constraints/property_constraint'

class PModule < ActiveRecord::Base
  belongs_to :catalog
  has_and_belongs_to_many :programs
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :courses, dependent: :destroy
  has_many :sub_modules, class_name: "PModule", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "PModule"

  scope :without_parent, -> {where(parent_id: nil)}

	def self.find_by_property(property_type, property_value, catalog)
		catalog.p_modules.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value).first
	end

	def mandatory?
		if mandatory.eql? "OUI"
			return true
		else
			return false
		end
	end

	def self.header
		return ["NAME", "CREDITS", "MIN", "MAX", "OBLIGATOIRE"]
	end

	def credits
		get_property("CREDITS").to_i
	end	

	def min
		result = get_property("MIN")
		if result.eql? "NONE"
			result = 0
		end
		return result.to_i
	end	

	def max
		result = get_property("MAX")
		if result.eql? "NONE"
			result = 999999
		end
		return result.to_i
	end

	def mandatory
		get_property("OBLIGATOIRE").to_s
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

	def self.page_name
		"MODULES"
	end

	def get_p_module_object(mandatory)
		p_module = ConstraintsChecker::Entities::PModule.new(id: self.id, name: self.name)
		p_module.add_constraint(ConstraintsChecker::Constraints::Min.new(p_module, self.min))-
		p_module.add_constraint(ConstraintsChecker::Constraints::Max.new(p_module, self.max))
		self.sub_modules.each do |m|
			p_module.add_children(m.get_p_module_object(true))
		end

		if mandatory
			course_ids = []
			self.courses.each do |course|
				course_ids << course.id
			end
			p_module.add_constraint(ConstraintsChecker::Constraints::Mandatory.new(p_module, course_ids))
		end

		return p_module
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
    props["NAME"] = self.name
    self.properties.each do |p|
      props[p.p_type.to_s] = p.value.to_s unless p.p_type.eql? "NAME"
    end
    props
  end
private
	def get_property(property_type)
		p = self.properties.where(p_type: property_type).first
		if p.nil? 
			return "NONE"
		else
			return p.value
		end
	end
end
