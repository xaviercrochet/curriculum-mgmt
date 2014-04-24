require 'entity'
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

      def print
        p @name
        @p_modules.each do |pm|
          pm.print
        end
        @courses.each do |c|
          c.print
        end
      end
    end
  end
end
