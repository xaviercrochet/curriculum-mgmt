require 'constraints_checker/entities/course'

class Course < ActiveRecord::Base
  #default_scope includes(:properties) deprecated!
  has_and_belongs_to_many :programs
  belongs_to :p_module
  belongs_to :catalog
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :constraints, dependent: :destroy

  scope :without_parent, -> {where(p_module_id: nil)}

  def build(properties)
  	p "Building course properties ..."
  	properties.each do |key, value|
  		@p = self.properties.new
  		@p.p_type = key.to_s
  		@p.value = value.to_s
  		@p.save
  	end
  end

  def self.default_scope
    self.includes(:properties)
  end

  def self.page_name
    "COURS"
  end

  def name
    get_property("SIGLE")
  end

  def credits
    get_property("CREDITS")
  end

  def semester
    get_property("SEMESTRE")
  end

  def mandatory
    get_property("OBLIGATOIRE")
  end


  def self.header
    return ["SIGLE", "CREDITS", "SEMESTRE", "OBLIGATOIRE"]
  end

  def self.find_by_property(property_type, property_value, catalog)
    catalog.courses.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value.to_s).first
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

  def get_course_object(passed)
    course = ConstraintsChecker::Entities::Course.new(name: self.name, id: self.id, passed: passed, parent_id: self.p_module_id)
    self.constraints.each do |c|
      course.add_constraint(c.get_constraint_object(course))
    end
    return course
  end

  def properties_to_hash
    props = Hash.new
    props["SIGLE"] = self.name
    self.properties.each do |p|
      props[p.p_type.to_s] = p.value.to_s unless p.p_type.eql? "SIGLE"
    end
    props
  end

  def as_json(option={})
    {
      :name => self.name
    }
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
