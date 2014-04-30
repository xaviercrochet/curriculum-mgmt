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
    end

    class CorequisiteSet < ConstraintSet
      def initialize(set_type, course, target_ids)
        super(set_type, "COREQUISITE", course, target_ids)
      end
    end

    class PrerequisiteSet < ConstraintSet
      def initialize(set_type, course, target_ids)
        super(set_type, "PREREQUISITE", course.target_ids)
      end
    end

    class OrPrerequisite < PrerequisiteSet
      def initialize(course, target_ids)
        super("OR", course, target_ids)
      end

      def check
      end
    end

    class XorPrerequisite < PrerequisiteSet

      def initialize(course, target_ids)
        super("XOR", course, target_ids)
      end

      def check
      end
    end

    class OrCorequisite < CorequisiteSet
      
      def initialize(course, target_ids)
        super("OR", course, target_ids)
      end

      def check
        logs = {or_corequisites_missing: []}
        results = []
        @target_ids.each do |id|
          if @course.find_course(id).nil?
            logs[:or_corequisites_missing] << id
          end
        end
        p logs
        logs = true if logs[:or_corequisites_missing].size ==  0
        return logs
      end
    end

    class XorCorequisite < CorequisiteSet

      def initialize(course, target_ids)
        super("XOR", course, target_ids)
      end

      def check
        logs = {or_corequisites_missing: []}
        results = []
        @target_ids.each do |id|
          if @course.find_course(id).nil?
            logs[:or_corequisites_missing] << id
          end
        end
        logs = true unless ! logs[:or_corequisites_missing].size ==  1
        return logs
      end
    end
  end
end
  