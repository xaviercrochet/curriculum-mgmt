class Course < ActiveRecord::Base

  attr_accessor :course_object
  default_scope includes(:properties)
  has_and_belongs_to_many :user_catalogs
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

  def name
    p = self.properties.where(:p_type => 'SIGLE').first
    if p.nil?
      self.properties.first.value
    else
      p.value
    end
  end

  def credits
    c = self.properties.where(:p_type => 'CREDITS').first
    if p.nil?
      'NONE'
    else
      c.value
    end
  end


  def binary_corequisites
       constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'COREQUISITE'}, :constraint_set_types => {:name => 'BINARY'})
  end

  def xor_prerequisites
      constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'PREREQUISITE'}, :constraint_set_types => {:name => 'X'})

  end

  def xor_corequisites
    constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'COREQUISITE'}, :constraint_set_types => {:name => 'X'})

  end

  def or_prerequisites
    constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'PREREQUISITE'}, :constraint_set_types => {:name => 'OR'})
  end

  def or_corequisites
    constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'COREQUISITE'}, :constraint_set_types => {:name => 'OR'})
  end

  def binary_prerequisites
    constraints = self.constraints.includes(:constraint_type, constraint_set: :constraint_set_type).where(:constraint_types => {:name => 'PREREQUISITE'}, :constraint_set_types => {:name => 'BINARY'})
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

  def to_object(catalog)
     self.course_object = ConstraintsChecker::Entities::Course.new(self.id, self.name, self.credits, catalog, nil)
     self.binary_prerequisites.each do |c|
      c.pairs.each do |pre|
        self.course_object.add_constraint(pre.to_object(self.course_object))
      end
    end
    self.binary_corequisites.each do |c|
      c.pairs.each do |co|
        self.course_object.add_constraint(co.to_object(self.course_object))
      end
    end

    p "Constriants : "+self.course_object.constraints.size.to_s
    self.course_object
  end

  def properties_to_hash
    props = Hash.new
    self.properties.each do |p|
      props[p.p_type.to_s] = p.value.to_s
    end
    props
  end

  def as_json(option={})
    {
      :name => self.name
    }
  end 
end
