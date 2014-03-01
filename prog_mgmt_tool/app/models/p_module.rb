class PModule < ActiveRecord::Base
  belongs_to :program
  has_many :properties, :as => :entity, dependent: :destroy
  has_many :courses, as: :block, dependent: :destroy
  has_many :sub_modules, dependent: :destroy
end
