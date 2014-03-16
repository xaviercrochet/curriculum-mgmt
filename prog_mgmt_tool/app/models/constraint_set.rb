class ConstraintSet < ActiveRecord::Base
	has_many :constraints, dependent: :destroy
	belongs_to :constraint_set_type

	def add_sources(edges)
		edges.each do |edge|
		end
	end
end
