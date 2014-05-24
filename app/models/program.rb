require 'constraints_checker/constraints/property_constraint'

class Program < ActiveRecord::Base
	has_many :properties, as: :entity, dependent: :destroy
	belongs_to :catalog
	has_many :student_programs, dependent: :destroy
	has_and_belongs_to_many :p_modules
	has_and_belongs_to_many :courses

	accepts_nested_attributes_for :properties
	validates_associated :properties


	def self.find_by_property(property_type, property_value, catalog)
		catalog.programs.includes(:properties).where('property.p_type' => property_type, 'property.p_value' => property_value).first
	end

	def self.page_name
		"PROGRAMMES"
	end

	def complete_name
		self.catalog.name + " : " + self.catalog.academic_year.name + " - " + self.name
	end

	def credits
		get_property("CREDITS")
	end

	def mandatory_modules
		modules = []
		self.p_modules.without_parent.each do |m|
			modules << m if m.mandatory?
		end
		return modules
	end

	def self.header
		return ["NAME", "MIN", "MAX", "CREDITS"]
	end

	def count_credits
		p self.name
		result = 0
		self.courses.each do |course|
			result += course.credits.to_i
		end
		self.p_modules.each do |p_module|
			result += p_module.count_credits.to_i
		end
		return result
	end



	def optional_modules
		modules = []
		self.p_modules.without_parent.each do |m|
			modules << m unless m.mandatory?
		end
		return modules
	end

	def first_semester_courses
		prgrm = Program.includes(:courses, p_modules: [:courses, {sub_modules: :courses}]).find(self.id)
		result = prgrm.courses.first_semester
		prgrm.p_modules.each do |pm|
			result += pm.courses.first_semester
			pm.sub_modules.each do |sm|
				result +=  sm.courses.first_semester
			end
		end
		return result
	end

	def second_semester_courses
		prgrm = Program.includes(:courses, p_modules: [:courses, {sub_modules: :courses}]).find(self.id)
		result = prgrm.courses.second_semester
		prgrm.p_modules.each do |pm|
			result +=  pm.courses.second_semester
			pm.sub_modules.each do |sm|
				result +=  sm.courses.second_semester
			end
		end
		return result
	end

	def first_semester_optional_courses
		prgrm = Program.includes(:courses, p_modules: [:courses, {sub_modules: :courses}]).where(id: self.id).first
		result = prgrm.courses.first_semester.optional
		prgrm.p_modules.each do |pm|
			result = result +  pm.courses.first_semester.optional
			pm.sub_modules.each do |sm|
				result = result +  sm.courses.first_semester.optional
			end
		end
		return result
	end

	def second_semester_optional_courses
		prgrm = Program.includes(:courses, p_modules: [:courses, {sub_modules: :courses}]).where(id: self.id).first
		result = prgrm.courses.second_semester.mandatory
		prgrm.p_modules.each do |pm|
			result = result +  pm.courses.second_semester.optional
			pm.sub_modules.each do |sm|
				result = result +  sm.courses.second_semester.optional
			end
		end
		return result
	end

	def mandatory_courses
		prgrm = Program.includes(:courses, p_modules: [:courses, {sub_modules: :courses}]).find(self.id)
		result = self.courses.mandatory
		prgrm.p_modules.each do |pm|
			result += pm.courses.mandatory
			pm.sub_modules.each do |sm|
				result +=  sm.courses.mandatory
			end
		end
		return result
	end

	def all_courses
		result = self.courses
		self.p_modules.each do |pm|
			result += pm.all_courses
		end

		return result

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
		name = 	get_property("NAME")
		if name.eql? ""
			name = "NONE"
		end
		return name
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
			result = 999
		end
		return result.to_i
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
