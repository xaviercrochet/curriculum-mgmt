require_relative '../constraint'

module ConstraintsChecker
  module Constraints
    class BinaryConstraint < Constraint
      
      attr_accessor :course
      #target => target de la contrainte, les dépendances d'un cours par exemple
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
        result = self.course.find_course(self.target_id)
        if result.nil?
          return {prerequisites_missing: [self.target_id]}
        # elsif ! result.passed
        #   return {prerequisites_not_passed: [self.target_id]}
        else
          if course.compare(result).eql? 1
            return true
          else
            return {prerequisites_missing: [self.target_id]}
          end
        end
      end
    end

    class Corequisite < BinaryConstraint
      def initialize(course, target_id)
        super(course, target_id)
      end

      def check
        result = self.course.find_course(self.target_id)
        if result.nil?
          return {corequisites_missing: [self.target_id]}
        else
          if course.compare(result).eql? -1
            return {corequisites_missing: [self.target_id]}
          else
            return true
          end
        end
      end
    end
  end
end