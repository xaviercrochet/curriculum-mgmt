class Course < ActiveRecord::Base
  belongs_to :block, polymorphic: true
  belongs_to :catalog
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :course_entities, dependent: :destroy
  has_many :constraints, dependent: :destroy

  def build(properties)
  	p "Building course properties ..."
  	properties.each do |key, value|
  		@p = self.properties.new
  		@p.p_type = key.to_s
  		@p.value = value.to_s
  		@p.save
  	end
  end


  def binary_corequisites
    constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'COREQUISITE'}, :constraint_set_types => {:name => 'BINARY'})

  end

  def binary_prerequisites
    constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'PREREQUISITE'}, :constraint_set_types => {:name => 'BINARY'})
  end

  def self.find_by_property(property_type, property_value, catalog)
    catalog.courses.includes(:properties).where('properties.p_type' => property_type, 'properties.value' => property_value.to_s).first
  end

  def update_properties(properties)
    self.properties.each do |p|
      p.destroy
    end
    properties.each do |key, value|
      self.properties.create(:p_type => key.to_s, :value => value.to_s)
    end
  end 
end
