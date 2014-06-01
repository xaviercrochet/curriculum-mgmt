require_relative '../constraint'

module ConstraintsChecker
  module Constraints
    class ConstraintSet < Constraint

      attr_accessor :set_type
      attr_accessor :type
      attr_accessor :courses
      attr_accessor :target_ids
      attr_accessor :id

      def initialize(id, set_type, type, course, target_ids)
        super()
        @id = id
        @set_type = set_type
        @type = type
        @course = course
        @target_ids = target_ids
      end

      # search recursively (through the parent-child renlation) for courses related to the target_ids array attribute
      def find_missing_dependencies
        results = []
        @target_ids.each do |id|
          if @course.find_course(id).nil?
            results << id
          else
          end
        end
        return results
      end
    end

    class CorequisiteSet < ConstraintSet
      def initialize(id, set_type, course, target_ids)
        super(id, set_type, "COREQUISITE", course, target_ids)
      end
      # same as parent method, but compare the year attribute for each course, to match the corequisite behaviour
      def find_missing_dependencies
        results = []
        @target_ids.each do |id|
          result = @course.find_course(id)
          if result.nil?
            results << id
          elsif ! result.nil and @course.compare(result).eql? -1
            results << id
          end
        end
        return results
      end

    end

    class PrerequisiteSet < ConstraintSet
      def initialize(id, set_type, course, target_ids)
        super(id, set_type, "PREREQUISITE", course, target_ids)
      end
      #same as corequisite_set methods
      def find_missing_dependencies
        results = []
        @target_ids.each do |id|
          result = @course.find_course(id)
          if result.nil?
            results << id
          elsif ! result.nil and @course.compare(result) < 1
            results << id
          end
        end
        return results
      end
    end

    class OrPrerequisite < PrerequisiteSet
      def initialize(id, course, target_ids)
        super(id, "OR", course, target_ids)
      end

      def check
        results = find_missing_dependencies
        if results.size < target_ids.size
          return true
        else
          @logs = {or_prerequisites_missing:[results]}
          return false
        end
      end
    end

    class XorPrerequisite < PrerequisiteSet

      def initialize(id, course, target_ids)
        super(id, "XOR", course, target_ids)
      end

      def check
        result = find_missing_dependencies
        if result.size == target_ids.size - 1
          return true
        else
          @logs =  {xor_prerequisites_missing: [target_ids]}
          return false
        end
      end
    end

    class OrCorequisite < CorequisiteSet
      
      def initialize(id, course, target_ids)
        super(id, "OR", course, target_ids)
      end

      def check
        results = find_missing_dependencies
        if results.size < target_ids.size
          return true
        else
          @logs =  {or_corequisites_missing:[results]}
          return false
        end
      end
    end

    class XorCorequisite < CorequisiteSet

      def initialize(id, course, target_ids)
        super(id, "XOR", course, target_ids)
      end

      def check
        result = find_missing_dependencies
        if result.size == target_ids.size - 1
          return true
        else
          @logs =  {xor_corequisites_missing: [target_ids]}
          return false
        end
      end
    end
  end
end
  