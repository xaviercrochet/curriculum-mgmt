require 'constraint'

module ConstraintsChecker
  module Constraints
    class PropertyConstraint < Constraint
      attr_accessor :target
      attr_accessor :property 
      attr_accessor :value

      def initialize(target, property, value)
        self.property = property
        self.target = target
        self.value = value
      end

      def check
        if ! target.property.nil?
          if ! target.property.eql? value
            {self.property.to_s => value.to_s}
          end
        else
          {self.property.to_s => 'not present'}
        end
        false
      end
    end

    class Min < PropertyConstraint

      def initialize(target, value)
        super(target, 'MIN', value)
      end

      def check
        if ! target.check_min(self.value)
          return {to_few_credits: self.target.id}
        else
          return true
        end
      end
    end

    class Max < PropertyConstraint

      def initialize(target, value)
        super(target, 'MAX', value)
      end

      def check
        if ! target.check_max(self.value)
          return {to_many_credits: self.target.id}
        else
          return true
        end
      end
    end
  end
end