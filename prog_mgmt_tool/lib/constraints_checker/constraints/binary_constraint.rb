require 'constraint'

module ConstraintsChecker
  module Constraints
    class BinaryConstraint < Constraint
      
      attr_accessor :source
      attr_accessor :target

      def initialize(source, target)
        self.source = source
        self.target = target
      end
    end

    class Prerequisite < BinaryConstraint
      
      def initialize(source, target)
        super(source, target)
      end

      def check
        p "Prerequisite check"
        course = target.catalog.find_course(self.source)
        if course.nil?
          p "Course not present!"
          {not_present: self.source}
        elsif ! course.passed
          p "Course present but not passed!"
          {not_passed: self.source}
        else
          p "Prerequisite check passed!"
          true
        end
      end
    end

    class Corequisite < BinaryConstraint
      def initialize(source, target)
        super(source, target)
      end

      def check
        p "Corequisite check"
        course = target.catalog.find_course(self.source)
        if course.nil?
          p "Course not present!"
          {not_present: self.source}
        else
          p "Corequisite check passed!"
          true
        end
      end
    end
  end
end