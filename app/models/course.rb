require 'constraints_checker/entities/course'

class Course < ActiveRecord::Base
  has_and_belongs_to_many :programs
  belongs_to :p_module
  belongs_to :catalog
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :constraints, dependent: :destroy
  scope :without_parent, -> {where(p_module_id: nil)}
  # scope :first_semester, -> {joins(:properties).where("properties.p_type" => "SEMESTRE", "properties.value" =>  "1")}
  scope :first_semester, ->{includes(:properties).merge(Property.first_semester).references(:properties)}
  scope :second_semester, -> {includes(:properties).merge(Property.second_semester).references(:properties)}
  scope :mandatory, -> {includes(:properties).merge(Property.mandatory).references(:properties)}
  scope :both_semesters, -> {includes(:properties).merge(Property.both_semesters).references(:properties)}
  scope :optional, -> {includes(:properties).merge(Property.optional).references(:properties)}
  scope :optional_and_from_first_semester, -> {Course.optional & Course.first_semester}
  scope :mandatory_and_from_first_semester, -> {Course.mandatory & Course.first_semester}
  
  def build(properties)
  	p "Building course properties ..."
  	properties.each do |key, value|
  		@p = self.properties.new
  		@p.p_type = key.to_s
  		@p.value = value.to_s
  		@p.save
  	end
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
    if get_property("OBLIGATOIRE").eql? "OUI"
      return "OUI"
    else
      return "NON"
    end
  end

  def mandatory?
    return mandatory.eql? "OUI"
  end

  def optional?
    return ! mandatory?
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

  def get_course_object(start_year, end_year)
    course = ConstraintsChecker::Entities::Course.new(name: self.name, id: self.id, start_year: start_year, end_year: end_year, parent_id: self.p_module_id, credits: self.credits, mandatory: self.mandatory?)
    self.constraints.each do |c|
      constraint = c.get_constraint_object(course)
      course.add_constraint(constraint) unless constraint.nil?
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
