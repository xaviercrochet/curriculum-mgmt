require 'entity'

module GraphParser
  module Entities
    class ConstraintSet < Entity
      attr_accessor :constraints
      attr_accessor :type

      def initialize(id, name)
        super(id, name)
        @constraints = []
        @type = name
      end

      def add_constraint(constraint)
        @constraints << constraint
      end

    end
  end
end