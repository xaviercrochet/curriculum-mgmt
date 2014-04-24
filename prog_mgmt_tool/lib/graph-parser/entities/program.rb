require 'entity'
require 'entities/p_module'
require 'entities/course'

module GraphParser
  module Entities
    class Program < Entity

      attr_accessor :p_modules
      attr_accessor :courses
      
      def initialize(id, name)
        super(id, name)
        @p_modules = {}
        @courses = {}
      end

      def add_course(id, course)
        @courses[id] = course
      end

      def add_p_module(id, p_module)
        @p_modules[id] = p_module
      end

      def count_courses
        result = @courses.size

        @p_modules.each do |key, value|
          result = result + value.count_courses
        end
        return result
      end

      def count_p_modules
        result = @p_modules.size

        @p_modules.each do |key, value|
          result = result + value.count_p_modules
        end
        return result
      end

      def print
        p "PROGRAM : " +@name
        @p_modules.each do |key,value|
          value.print
        end
        @courses.each do |key,value|
          value.print
        end
      end
    end
  end
end
