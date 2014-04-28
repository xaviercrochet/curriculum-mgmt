require_relative 'entity'
require_relative 'p_module'
require_relative 'course'

module GraphParser
  module Entities
    class Program < Entity

      attr_accessor :p_modules

      def initialize(id, name)
        super(id, name)
        @p_modules = []
      end

      def find_course(id)
        result = nil
        @courses.each do |c|
          if c.id.eql? id
            return result
          end
        end
        @p_modules.each do |m|
          result = m.find_course(id)
          if !result.nil?
            return result
          end
        end
        return result
      end
      
      def add_p_module(p_module)
        @p_modules << p_module
      end

      def count_p_modules
        result = @p_modules.size

        @p_modules.each do |m|
          result = result + m.count_p_modules
        end
        return result
      end

      def print
        p "PROGRAM : " +@name
        @p_modules.each do |m|
          value.print
        end
        @courses.each do |m|
          value.print
        end
      end
    end
  end
end
