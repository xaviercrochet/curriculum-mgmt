class ConstraintException < ActiveRecord::Base
  belongs_to :justification
  belongs_to :entity, polymorphic: true

end
