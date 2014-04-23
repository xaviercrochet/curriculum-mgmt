require 'constraint'

module ConstraintsChecker
  module Constraints
    class BinaryConstraint < Constraint
      
      attr_accessor :course
      attr_accessor :pair_id

      def initialize(course, pair_id)
        self.course = course
        self.pair_id = pair_id
      end
    end

    class Prerequisite < BinaryConstraint
      
      def initialize(course, pair_id)
        super(course, pair_id)
      end

      def check
        result = self.course.find_course(pair_id)
        if result.nil?
          return {prerequisite_missing: self.source}
        elsif ! result.passed
          return {not_passed: self.source}
        else
          return true
        end
      end
    end

    class Corequisite < BinaryConstraint
      def initialize(course, pair_id)
        super(course, pair_id)
      end

      def check
        result self.course.find_course(pair_id)
        if result.nil?
          {corequisite_missing: self.source}
        else
          true
        end
      end
    end
  end
end