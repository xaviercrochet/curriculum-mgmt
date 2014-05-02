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

      def find_dependencies
        results = []
        @target_ids.each do |id|
          p "result : "+@course.find_course(id).to_s
          if @course.find_course(id).nil?
            results << id
          end
        end
        return results
      end
    end

    class CorequisiteSet < ConstraintSet
      def initialize(set_type, course, target_ids)
        super(set_type, "COREQUISITE", course, target_ids)
      end
    end

    class PrerequisiteSet < ConstraintSet
      def initialize(set_type, course, target_ids)
        super(set_type, "PREREQUISITE", course, target_ids)
      end
    end

    class OrPrerequisite < PrerequisiteSet
      def initialize(course, target_ids)
        p "YIHA"
        super("OR", course, target_ids)
      end

      def check
        logs = {or_prerequisites_missing: []}
        results = find_dependencies
        results.each do |id|
          logs[:or_prerequisites_missing] << id
        end

        logs = true if logs[:or_prerequisites_missing].size > 0
        return logs
      end
    end

    class XorPrerequisite < PrerequisiteSet

      def initialize(course, target_ids)
        super("XOR", course, target_ids)
      end

      def check
        logs = {xor_prerequisites_missing: []}
        result = find_dependencies
        result.each do |id|
          logs[:xor_prerequisites_missing] << id
        end

        logs = true if logs[:xor_prerequisites_missing].size == 1
        return logs
      end
    end

    class OrCorequisite < CorequisiteSet
      
      def initialize(course, target_ids)
        super("OR", course, target_ids)
      end

      def check
        p "or corequisite check"
        logs = {or_corequisites_missing: []}
        results = find_dependencies
        results.each do |id|
          logs[:or_corequisites_missing] << id
        end
        logs = true if logs[:or_corequisites_missing].size ==  0
        return logs
      end
    end

    class XorCorequisite < CorequisiteSet

      def initialize(course, target_ids)
        super("XOR", course, target_ids)
      end

      def check
        logs = {xor_corequisites_missing: []}
        results = find_dependencies
        @results.each do |id|
          logs[:xor_corequisites_missing] << id
        end
        logs = true if logs[:or_corequisites_missing].size ==  1
        return logs
      end
    end
  end
end
  