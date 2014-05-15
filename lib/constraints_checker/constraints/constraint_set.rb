require_relative '../constraint'

module ConstraintsChecker
  module Constraints
    class ConstraintSet < Constraint

      attr_accessor :set_type
      attr_accessor :type
      attr_accessor :courses
      attr_accessor :target_ids

      def initialize(set_type, type, course, target_ids)
        @set_type = set_type
        @type = type
        @course = course
        @target_ids = target_ids
      end

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
      def initialize(set_type, course, target_ids)
        super(set_type, "COREQUISITE", course, target_ids)
      end

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
      def initialize(set_type, course, target_ids)
        super(set_type, "PREREQUISITE", course, target_ids)
      end

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
      def initialize(course, target_ids)
        super("OR", course, target_ids)
      end

      def check
        results = find_missing_dependencies
        if results.size < target_ids.size
          return true
        else
          return {or_prerequisites_missing:[results]}
        end
      end
    end

    class XorPrerequisite < PrerequisiteSet

      def initialize(course, target_ids)
        super("XOR", course, target_ids)
      end

      def check
        logs = {xor_prerequisites_missing: []}
        result = find_missing_dependencies
        if result.size == target_ids.size - 1
          return true
        else
          return {xor_prerequisites_missing: [target_ids]}
        end
      end
    end

    class OrCorequisite < CorequisiteSet
      
      def initialize(course, target_ids)
        super("OR", course, target_ids)
      end

      def check
        results = find_missing_dependencies
        if results.size < target_ids.size
          return true
        else
          return {or_corequisites_missing:[results]}
        end
      end
    end

    class XorCorequisite < CorequisiteSet

      def initialize(course, target_ids)
        super("XOR", course, target_ids)
      end

      def check
        logs = {xor_corequisites_missing: []}
        result = find_missing_dependencies
        if result.size == target_ids.size - 1
          return true
        else
          return {xor_corequisites_missing: [target_ids]}
        end
      end
    end
  end
end
  