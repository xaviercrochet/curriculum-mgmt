require_relative '../constraint'

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
          if target.class.name.eql? ConstraintsChecker::Catalog.name
            return {to_few_credits_in_program: [self.target.id]}
          else
            return {to_few_credits_in_module: [self.target.id]}
          end
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
          if target.class.name.eql? ConstraintsChecker::Catalog.name
            return {to_many_credits_in_program: [self.target.id]}
          else
            return {to_many_credits_in_module: [self.target.id]}
          end
        else
          return true
        end
      end
    end

    class Mandatory < PropertyConstraint
      attr_accessor :children_ids

      def initialize(target, children_ids)
        super(target, "MANDATORY", true)
        self.children_ids = children_ids
      end

      def check
        missing_ids = []
        self.children_ids.each do |id|
          result = self.target.find_course(id)
          if result.nil?
            missing_ids << id
          end
        end
        return {courses_missing_in_module: {self.target.id => missing_ids}}
      end
    end

    class MandatoryCourse < PropertyConstraint

      attr_accessor :course_id

      def initialize(catalog, course_id)
        super(catalog, 'MANDATORY', true)
        self.course_id = course_id
      end

      def check
        result = target.find_course(course_id)
        if result.nil?
          return {mandatory_courses_missing: [course_id]}
        else
          return true
        end
      end
    end
  end
end