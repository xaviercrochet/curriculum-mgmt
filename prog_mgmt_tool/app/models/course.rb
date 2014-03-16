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

  def self.find_by_property(property_type, property_value)
  end 
end
