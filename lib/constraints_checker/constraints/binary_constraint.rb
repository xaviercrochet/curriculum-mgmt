require_relative '../constraint'

module ConstraintsChecker
  module Constraints
    class BinaryConstraint < Constraint
      
      attr_accessor :course
      #target => target de la contrainte, les dépendances d'un cours par exemple
      attr_accessor :target_id
      attr_accessor :id

      def initialize(id, course, target_id)
        super()
        @id = id
        self.course = course
        self.target_id = target_id
      end
    end

    class Prerequisite < BinaryConstraint
      
      def initialize(id, course, target_id)
        super(id, course, target_id)
      end

      #first we look for the course
      #second we check if the course has been folowed  "au plus tard" during the previous year (see prerequisite definition)
      def check
        result = self.course.find_course(self.target_id)
        if result.nil?
          @logs =  {prerequisites_missing: [self.target_id]}
          return false
        else
          if course.compare(result).eql? 1
            return true
          else
            @logs =  {prerequisites_missing: [self.target_id]}
            return false
          end
        end
      end
    end

    class Corequisite < BinaryConstraint
      def initialize(id, course, target_id)
        super(id, course, target_id)
      end

      #first we look for the course
      #second we check if the course has been folowed "au plu tard" during the current year
      def check
        result = self.course.find_course(self.target_id)
        if result.nil?
          @logs =  {corequisites_missing: [self.target_id]}
          return false
        else
          if course.compare(result).eql? -1
            @logs =  {corequisites_missing: [self.target_id]}
            return false
          else
            return true
          end
        end
      end
    end
  end
end