require 'constraint'

module ConstraintsChecker
  module Constraints
    class BinaryConstraint < Constraint
      
      attr_accessor :course
      attr_accessor :target_id

      def initialize(course, target_id)
        self.course = course
        self.target_id = target_id
      end
    end

    class Prerequisite < BinaryConstraint
      
      def initialize(course, target_id)
        super(course, target_id)
      end

      def check
        result = self.course.find_course(target_id)
        if result.nil?
          return {prerequisite_missing: self.target_id}
        elsif ! result.passed
          return {not_passed: self.target_id}
        else
          return true
        end
      end
    end

    class Corequisite < BinaryConstraint
      def initialize(course, target_id)
        super(course, target_id)
      end

      def check
        result = self.course.find_course(target_id)
        if result.nil?
          {corequisite_missing: self.target_id}
        else
          true
        end
      end
    end
  end
end