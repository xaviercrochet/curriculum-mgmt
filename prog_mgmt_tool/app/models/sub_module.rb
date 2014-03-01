class SubModule < ActiveRecord::Base
  belongs_to :p_module
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :courses, as: :block, dependent: :destroy
end
